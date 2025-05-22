package controllers

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"

	"github.com/cloudinary/cloudinary-go/v2"
	"github.com/cloudinary/cloudinary-go/v2/api/uploader"

	"github.com/HarDizzeR/Project/backend/internal/database"
	"github.com/HarDizzeR/Project/backend/internal/helpers"
	"github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/HarDizzeR/Project/backend/internal/models"
)

func GetUsers() gin.HandlerFunc {
	return func(c *gin.Context) {

		ctx, cancel := context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		// Parse and validate pagination parameters
		recPerPage := 10 // Default value
		if limit := c.Query("RecordPerPage"); limit != "" {
			if val, err := strconv.Atoi(limit); err == nil && val > 0 && val <= 100 {
				recPerPage = val
			}
		}

		page := 1 // Default value
		if pageStr := c.Query("Page"); pageStr != "" {
			if val, err := strconv.Atoi(pageStr); err == nil && val > 0 {
				page = val
			}
		}

		startIndex := (page - 1) * recPerPage

		// Use more efficient aggregation pipeline
		matchStage := bson.D{{Key: "$match", Value: bson.D{}}}

		facetStage := bson.D{{Key: "$facet", Value: bson.D{
			{Key: "metadata", Value: bson.A{
				bson.D{{Key: "$count", Value: "total"}},
			}},
			{Key: "data", Value: bson.A{
				bson.D{{Key: "$skip", Value: startIndex}},
				bson.D{{Key: "$limit", Value: recPerPage}},
			}},
		}}}

		projectStage := bson.D{{Key: "$project", Value: bson.D{
			{Key: "length", Value: bson.D{{Key: "$arrayElemAt", Value: bson.A{"$metadata.total", 0}}}},
			{Key: "users", Value: "$data"},
		}}}

		cursor, err := userCollection.Aggregate(ctx, mongo.Pipeline{
			matchStage, facetStage, projectStage,
		})
		if err != nil {
			logger.Errorf("Failed to list users: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error while listing users"})
			return
		}
		defer cursor.Close(ctx)

		var results []bson.M
		if err := cursor.All(ctx, &results); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error while decoding results"})
			return
		}
		if len(results) > 0 {
			c.JSON(http.StatusOK, results[0])
		} else {
			c.JSON(http.StatusOK, gin.H{"total_count": 0, "user_items": []bson.M{}})
		}
	}

}

func GetUser() gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.Param("id")

		if err := helpers.MatchUserToid(c, userID); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		id, err := bson.ObjectIDFromHex(userID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid User ID"})
			return
		}

		var user bson.M
		err = userCollection.FindOne(ctx, bson.M{"_id": id}).Decode(&user)

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, user)
	}
}

func GetMyData() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 1. Get user ID from context
		userId := c.GetString("id")
		if userId == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID missing"})
			return
		}

		// 2. Convert to ObjectID
		objId, err := bson.ObjectIDFromHex(userId)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
			return
		}

		// 3. Fetch from Mongo
		var user models.User
		if err := database.Users().
			FindOne(c.Request.Context(), bson.M{"_id": objId}).
			Decode(&user); err != nil {

			if err == mongo.ErrNoDocuments {
				c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
			} else {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch user data"})
			}
			return
		}

		// 4. Generate weekly display
		currentTime := time.Now()
		weeklyDisplay := helpers.GenerateSunToSatWeeklyDisplay(user.DailyCompletions, currentTime)

		// 5. Build response with weekly_display
		resp := struct {
			models.User
			WeeklyDisplay [7]interface{} `json:"weekly_display"`
		}{
			User:          user,
			WeeklyDisplay: weeklyDisplay,
		}

		// 6. Return
		c.JSON(http.StatusOK, resp)
	}
}

func DeleteUser() gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.Param("id")

		if err := helpers.MatchUserToid(c, userID); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
			return
		}
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		var user models.User

		id, err := bson.ObjectIDFromHex(userID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid format"})
			return
		}

		err = userCollection.FindOneAndDelete(ctx, bson.M{"_id": id}).Decode(&user)

		if err != nil {
			logger.Errorf("Failed to delete user %s: %v", userID, err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		logger.Infof("User deleted successfully: %s", userID)
		c.JSON(http.StatusOK, gin.H{"message": "User was deleted successfully", "user": user})
	}

}

// Update User include password update
func UpdateUser() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 1. Authorization + ObjectID parsing
		userID := c.Param("id")
		if err := helpers.MatchUserToid(c, userID); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
			return
		}
		oid, err := bson.ObjectIDFromHex(userID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID format"})
			return
		}

		// Initialize Cloudinary
		cld, err := cloudinary.NewFromURL(os.Getenv("CLOUDINARY_URL"))
		if err != nil {
			logger.Errorf("Failed to initialize Cloudinary: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Image service configuration error"})
			return
		}

		// 2. Build the $set document
		set := bson.M{}

		// 3. Handle optional avatar upload (multipart/form-data "avatar")
		if fh, err := c.FormFile("avatar"); err == nil && fh != nil {
			file, err := fh.Open()
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "could not open avatar file"})
				return
			}
			defer file.Close()

			logger.Infof("Processing avatar upload: %s (%d bytes)", fh.Filename, fh.Size)

			// Upload with eager transformation: c_thumb,g_auto,w_200,h_200,r_max
			uploadParams := uploader.UploadParams{
				Folder: "profile_pics",
				Eager:  "c_thumb,g_auto,w_200,h_200,r_max",
			}

			resp, err := cld.Upload.Upload(context.Background(), file, uploadParams)
			if err != nil {
				logger.Errorf("Failed to upload avatar: %v", err)
				c.JSON(http.StatusBadGateway, gin.H{"error": "failed to upload avatar"})
				return
			}

			logger.Infof("Upload successful, URL: %s, EagerCount: %d", resp.SecureURL, len(resp.Eager))

			// Use the transformed URL (circle thumb), fallback to original if missing
			if len(resp.Eager) > 0 {
				set["avatar_url"] = resp.Eager[0].SecureURL
			} else {
				set["avatar_url"] = resp.SecureURL
			}
		}

		// 4. Process form fields directly for better debugging
		// Handle text fields directly from the form data
		if username := c.PostForm("username"); username != "" {
			logger.Infof("Updating username to: %s", username)
			set["username"] = username
		}

		if email := c.PostForm("email"); email != "" {
			logger.Infof("Updating email to: %s", email)
			set["email"] = email
		}

		if heightStr := c.PostForm("height"); heightStr != "" {
			if height, err := strconv.ParseFloat(heightStr, 64); err == nil {
				logger.Infof("Updating height to: %f", height)
				set["height"] = height
			} else {
				logger.Errorf("Failed to parse height: %v", err)
			}
		}

		if weightStr := c.PostForm("weight"); weightStr != "" {
			if weight, err := strconv.ParseFloat(weightStr, 64); err == nil {
				logger.Infof("Updating weight to: %f", weight)
				set["weight"] = weight
			} else {
				logger.Errorf("Failed to parse weight: %v", err)
			}
		}

		if gender := c.PostForm("gender"); gender != "" {
			logger.Infof("Updating gender to: %s", gender)
			set["gender"] = gender
		}

		if birthDateStr := c.PostForm("birth_date"); birthDateStr != "" {
			birthDate, err := time.Parse(time.RFC3339, birthDateStr)
			if err != nil {
				logger.Errorf("Failed to parse birth_date: %v", err)
			} else {
				logger.Infof("Updating birth_date to: %s", birthDate)
				set["birth_date"] = birthDate
			}
		}

		// Handle JSON payload (for when not using multipart)
		if c.ContentType() == "application/json" {
			var jsonPayload struct {
				Username  *string    `json:"username"`
				Email     *string    `json:"email"`
				Height    *float64   `json:"height"`
				BirthDate *time.Time `json:"birth_date"`
				Weight    *float64   `json:"weight"`
				Gender    *string    `json:"gender"`
			}

			if err := c.ShouldBindJSON(&jsonPayload); err == nil {
				if jsonPayload.Username != nil {
					set["username"] = *jsonPayload.Username
				}
				if jsonPayload.Email != nil {
					set["email"] = *jsonPayload.Email
				}
				if jsonPayload.Height != nil {
					set["height"] = *jsonPayload.Height
				}
				if jsonPayload.BirthDate != nil && !jsonPayload.BirthDate.IsZero() {
					set["birth_date"] = *jsonPayload.BirthDate
				}
				if jsonPayload.Weight != nil {
					set["weight"] = *jsonPayload.Weight
				}
				if jsonPayload.Gender != nil {
					set["gender"] = *jsonPayload.Gender
				}
			}
		}

		// 5. Check if we have any fields to update
		if len(set) == 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "No fields to update"})
			return
		}

		// Bump the updated_at timestamp
		set["updated_at"] = time.Now()

		// 6. Perform the update
		ctx, cancel := context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()
		collection := database.Users()

		logger.Infof("Updating user %s with fields: %+v", userID, set)

		res, err := collection.UpdateOne(ctx, bson.M{"_id": oid}, bson.M{"$set": set})
		if err != nil {
			logger.Errorf("Failed to update user %s: %v", userID, err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "database error"})
			return
		}
		if res.MatchedCount == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
			return
		}

		// 7. Return the updated user
		var updated models.User
		if err := collection.FindOne(ctx, bson.M{"_id": oid}).Decode(&updated); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "could not fetch updated user"})
			return
		}
		// If any updated fields (e.g. AccumDistance if it were part of this update) trigger achievements:
		c.JSON(http.StatusOK, gin.H{
			"message": "User updated successfully",
			"user":    updated,
		})
	}
}

// controllers/user.go

func AssignRandomQuests() gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.GetString("id")

		objectID, err := bson.ObjectIDFromHex(userID)
		if err != nil {
			logger.Errorf("Invalid user ID format: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID format"})
			return
		}

		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		// Retrieve the current user's data to get rank and check quests
		var user models.User
		err = userCollection.FindOne(ctx, bson.M{"_id": objectID}).Decode(&user)
		if err != nil {
			logger.Errorf("Failed to get user: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get user"})
			return
		}

		// Separate custom quests from daily quests
		var customQuests, dailyQuests []models.Quest
		var hasRunningQuest bool

		for _, quest := range user.CurrentQuests {
			if quest.IsCustom {
				customQuests = append(customQuests, quest)
			} else if quest.Type != nil && *quest.Type == "Running" {
				// Check if the running quest is still valid (assigned after today's midnight)
				now := time.Now().In(quest.GivenAt.Location())
				todayMidnight := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())

				if quest.GivenAt.After(todayMidnight) {
					dailyQuests = append(dailyQuests, quest)
					hasRunningQuest = true
				}
			}
		}

		// If we already have a valid running quest, just return the combined quests
		if hasRunningQuest {
			combinedQuests := append(customQuests, dailyQuests...)
			c.JSON(http.StatusOK, gin.H{
				"quests":  combinedQuests,
				"message": "Found existing valid running quest",
			})
			return
		}

		// Find the single running quest
		var runningQuest models.Quest
		runningQuestType := "Running"
		err = questCollection.FindOne(ctx, bson.M{"type": runningQuestType}).Decode(&runningQuest)
		if err != nil {
			logger.Errorf("Error fetching running quest: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch running quest"})
			return
		}

		// Get the multiplier based on user's rank
		multiplier := helpers.GetQuestMultiplier(user.Rank)

		// Apply rank multiplier to rewards and goal
		now := time.Now()
		runningQuest.GivenAt = now

		if runningQuest.XPReward != nil {
			xpReward := *runningQuest.XPReward * multiplier
			runningQuest.XPReward = &xpReward
		}

		if runningQuest.GoldReward != nil {
			goldReward := *runningQuest.GoldReward * multiplier
			runningQuest.GoldReward = &goldReward
		}

		// Also apply multiplier to the goal for higher ranks
		if runningQuest.Goal != nil {
			goal := *runningQuest.Goal * multiplier
			runningQuest.Goal = &goal
		}

		// Mark as not custom
		runningQuest.IsCustom = false

		// Combine custom quests with the new running quest
		newQuests := append(customQuests, runningQuest)

		// Update the user document to assign these quests
		filter := bson.M{"_id": objectID}
		update := bson.M{"$set": bson.M{"quests": newQuests}}
		updateResult, err := userCollection.UpdateOne(ctx, filter, update)
		if err != nil {
			logger.Errorf("Error updating user quest: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to assign quest"})
			return
		}

		if updateResult.MatchedCount == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"quests":     newQuests,
			"multiplier": multiplier,
		})
	}
}

func UpdateUserStats() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get user ID from URL
		userID := c.Param("id")

		// Convert string ID to MongoDB ObjectID
		objID, err := bson.ObjectIDFromHex(userID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
			return
		}

		// Bind and validate request
		var updateData models.Stats
		if err := c.ShouldBindJSON(&updateData); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
			return
		}

		// Build the MongoDB update document
		update := bson.M{"$set": bson.M{}}
		setValues := update["$set"].(bson.M)

		if updateData.Vitality != nil {
			setValues["stats.vitality"] = *updateData.Vitality
		}
		if updateData.Strength != nil {
			setValues["stats.strength"] = *updateData.Strength
		}
		if updateData.Endurance != nil {
			setValues["stats.endurance"] = *updateData.Endurance
		}
		if updateData.Agility != nil {
			setValues["stats.agility"] = updateData.Agility
		}

		// Check if any fields were provided
		if len(setValues) == 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "No fields to update"})
			return
		}

		// Update in MongoDB
		filter := bson.M{"_id": objID}
		result, err := userCollection.UpdateOne(context.Background(), filter, update)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database update failed"})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"status":  "success",
			"updated": result.ModifiedCount,
		})
	}

}

func CreateCustomQuest() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get authenticated user ID from context
		userID := c.GetString("id")
		if userID == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID not found in context"})
			return
		}

		// Parse request body for quest details
		var questReq struct {
			Name       string  `json:"name" binding:"required,min=3,max=100"`
			XPReward   float64 `json:"xp_reward" bson:"xp_reward" validate:"required,gte=0"`
			GoldReward float64 `json:"gold_reward" bson:"gold_reward" validate:"required,gte=0"`
			Type       string  `json:"type" binding:"required,oneof=Mental Habit"`
		}

		if err := c.ShouldBindJSON(&questReq); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request: " + err.Error()})
			return
		}

		// Convert user ID to ObjectID
		userOID, err := bson.ObjectIDFromHex(userID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID format"})
			return
		}

		// Create quest object
		newQuest := models.Quest{
			ID:          bson.NewObjectID(),
			Name:        &questReq.Name,
			XPReward:    &questReq.XPReward,
			GoldReward:  &questReq.GoldReward,
			Type:        &questReq.Type,
			IsCompleted: false,
			GivenAt:     time.Now(),
		}

		// Mark quest as custom to prevent it from being removed during daily quest assignments
		newQuest.IsCustom = true

		// Get user collection
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		userCollection := database.Users()

		// Add to user's quests using $push operator
		update := bson.M{
			"$push": bson.M{
				"quests": newQuest,
			},
		}

		result, err := userCollection.UpdateOne(ctx, bson.M{"_id": userOID}, update)
		if err != nil {
			logger.Errorf("Error adding custom quest: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to add custom quest"})
			return
		}

		if result.MatchedCount == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
			return
		}

		c.JSON(http.StatusCreated, gin.H{
			"message": "Custom quest created successfully",
			"quest":   newQuest,
		})
	}
}

// EquipItem equips an item to the user and updates their stats
func EquipItem() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get user ID from context
		userID := c.GetString("id")
		if userID == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID not found in context"})
			return
		}

		// Parse request body for item details
		var req struct {
			ItemID string `json:"item_id" binding:"required"`
			Slot   string `json:"slot" binding:"required,oneof=helmet chestplate leggings boots weapon"`
		}

		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request: " + err.Error()})
			return
		}

		// Convert IDs to ObjectID
		userOID, err := bson.ObjectIDFromHex(userID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
			return
		}

		itemOID, err := bson.ObjectIDFromHex(req.ItemID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid item ID"})
			return
		}

		// Check if item exists and get its details
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		itemsCollection := database.Items()
		userCollection := database.Users()

		var item models.Item
		err = itemsCollection.FindOne(ctx, bson.M{"_id": itemOID}).Decode(&item)
		if err != nil {
			if err == mongo.ErrNoDocuments {
				c.JSON(http.StatusNotFound, gin.H{"error": "item not found"})
			} else {
				logger.Errorf("Database error: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to retrieve item"})
			}
			return
		}

		// Verify item is permanent (only permanent items can be equipped)
		if !item.IsPermanent {
			c.JSON(http.StatusBadRequest, gin.H{"error": "only permanent items can be equipped"})
			return
		}

		// Verify item is of type equipment
		if item.Type != "equipment" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "only equipment items can be equipped"})
			return
		}

		// Check if slot matches item's slot
		if item.Slot != req.Slot {
			c.JSON(http.StatusBadRequest, gin.H{"error": "requested slot does not match item's slot"})
			return
		}

		// Get user to update equipped items and stats
		var user models.User
		err = userCollection.FindOne(ctx, bson.M{"_id": userOID}).Decode(&user)
		if err != nil {
			if err == mongo.ErrNoDocuments {
				c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
			} else {
				logger.Errorf("Database error: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to retrieve user"})
			}
			return
		}

		// NEW: Verify that the user owns this item by checking their inventory
		inventoryCollection := database.Inventories()
		var inventory models.Inventory
		err = inventoryCollection.FindOne(ctx, bson.M{"_id": user.InventoryID}).Decode(&inventory)
		if err != nil {
			if err == mongo.ErrNoDocuments {
				c.JSON(http.StatusNotFound, gin.H{"error": "user inventory not found"})
			} else {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "database error while retrieving inventory"})
			}
			return
		}
		owned := false
		for _, ownedItem := range inventory.Items {
			if ownedItem == itemOID {
				owned = true
				break
			}
		}
		if !owned {
			c.JSON(http.StatusBadRequest, gin.H{"error": "item must be purchased before equipping"})
			return
		}

		// Update equipped items based on slot
		// Create equipped items map if it doesn't exist
		if user.EquippedItems == nil {
			user.EquippedItems = make(map[string]bson.ObjectID)
		}

		// Store previous item for stat calculation
		var previousItemID bson.ObjectID
		if prevID, exists := user.EquippedItems[req.Slot]; exists {
			previousItemID = prevID
		}

		// Equip new item
		user.EquippedItems[req.Slot] = itemOID

		// Calculate stat changes
		// If there was a previous item, remove its stats first
		if !previousItemID.IsZero() {
			var prevItem models.Item
			err = itemsCollection.FindOne(ctx, bson.M{"_id": previousItemID}).Decode(&prevItem)
			if err == nil && prevItem.StatBonuses != nil {
				// Remove previous stat bonuses
				if user.Stats.Strength != nil && prevItem.StatBonuses.Strength != nil {
					newStrength := *user.Stats.Strength - *prevItem.StatBonuses.Strength
					user.Stats.Strength = &newStrength
				}
				if user.Stats.Endurance != nil && prevItem.StatBonuses.Endurance != nil {
					newEndurance := *user.Stats.Endurance - *prevItem.StatBonuses.Endurance
					user.Stats.Endurance = &newEndurance
				}
				if user.Stats.Agility != nil && prevItem.StatBonuses.Agility != nil {
					newAgility := *user.Stats.Agility - *prevItem.StatBonuses.Agility
					user.Stats.Agility = &newAgility
				}
				if user.Stats.Vitality != nil && prevItem.StatBonuses.Vitality != nil {
					newVitality := *user.Stats.Vitality - *prevItem.StatBonuses.Vitality
					user.Stats.Vitality = &newVitality
				}
			}
		}

		// Add new item's stat bonuses
		if item.StatBonuses != nil {
			if user.Stats.Strength != nil && item.StatBonuses.Strength != nil {
				newStrength := *user.Stats.Strength + *item.StatBonuses.Strength
				user.Stats.Strength = &newStrength
			} else if item.StatBonuses.Strength != nil {
				user.Stats.Strength = item.StatBonuses.Strength
			}

			if user.Stats.Endurance != nil && item.StatBonuses.Endurance != nil {
				newEndurance := *user.Stats.Endurance + *item.StatBonuses.Endurance
				user.Stats.Endurance = &newEndurance
			} else if item.StatBonuses.Endurance != nil {
				user.Stats.Endurance = item.StatBonuses.Endurance
			}

			if user.Stats.Agility != nil && item.StatBonuses.Agility != nil {
				newAgility := *user.Stats.Agility + *item.StatBonuses.Agility
				user.Stats.Agility = &newAgility
			} else if item.StatBonuses.Agility != nil {
				user.Stats.Agility = item.StatBonuses.Agility
			}

			if user.Stats.Vitality != nil && item.StatBonuses.Vitality != nil {
				newVitality := *user.Stats.Vitality + *item.StatBonuses.Vitality
				user.Stats.Vitality = &newVitality
			} else if item.StatBonuses.Vitality != nil {
				user.Stats.Vitality = item.StatBonuses.Vitality
			}
		}

		// Update user in database
		update := bson.M{
			"$set": bson.M{
				"equipped_items": user.EquippedItems,
				"stats":          user.Stats,
				"updated_at":     time.Now(),
			},
		}

		result, err := userCollection.UpdateOne(ctx, bson.M{"_id": userOID}, update)
		if err != nil {
			logger.Errorf("Failed to update user: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to equip item"})
			return
		}

		if result.MatchedCount == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"message": "Item equipped successfully",
			"item":    item,
			"stats":   user.Stats,
		})
	}
}

// UnequipItem removes an equipped item from a specified slot and updates user stats
func UnequipItem() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get user ID from context
		userID := c.GetString("id")
		if userID == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID not found in context"})
			return
		}

		// Parse request body for slot details
		var req struct {
			Slot string `json:"slot" binding:"required,oneof=helmet chestplate leggings boots weapon"`
		}

		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request: " + err.Error()})
			return
		}

		// Convert userID to ObjectID
		userOID, err := bson.ObjectIDFromHex(userID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
			return
		}

		// Get user to check equipped items and update stats
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		userCollection := database.Users()
		itemsCollection := database.Items()

		var user models.User
		err = userCollection.FindOne(ctx, bson.M{"_id": userOID}).Decode(&user)
		if err != nil {
			if err == mongo.ErrNoDocuments {
				c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
			} else {
				logger.Errorf("Database error: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to retrieve user"})
			}
			return
		}

		// Check if user has an item equipped in the specified slot
		if user.EquippedItems == nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "user has no equipped items"})
			return
		}

		itemID, equipped := user.EquippedItems[req.Slot]
		if !equipped {
			c.JSON(http.StatusBadRequest, gin.H{"error": "no item equipped in specified slot"})
			return
		}

		// Get the item details to remove its stat bonuses
		var item models.Item
		err = itemsCollection.FindOne(ctx, bson.M{"_id": itemID}).Decode(&item)
		if err != nil {
			logger.Errorf("Failed to retrieve item %s: %v", itemID.Hex(), err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to retrieve item details"})
			return
		}

		// Remove the item's stat bonuses from the user's stats
		if item.StatBonuses != nil {
			if user.Stats.Strength != nil && item.StatBonuses.Strength != nil {
				newStrength := *user.Stats.Strength - *item.StatBonuses.Strength
				user.Stats.Strength = &newStrength
			}
			if user.Stats.Endurance != nil && item.StatBonuses.Endurance != nil {
				newEndurance := *user.Stats.Endurance - *item.StatBonuses.Endurance
				user.Stats.Endurance = &newEndurance
			}
			if user.Stats.Agility != nil && item.StatBonuses.Agility != nil {
				newAgility := *user.Stats.Agility - *item.StatBonuses.Agility
				user.Stats.Agility = &newAgility
			}
			if user.Stats.Vitality != nil && item.StatBonuses.Vitality != nil {
				newVitality := *user.Stats.Vitality - *item.StatBonuses.Vitality
				user.Stats.Vitality = &newVitality
			}
		}

		// Remove the item from the equipped items
		delete(user.EquippedItems, req.Slot)

		// Update user in database
		update := bson.M{
			"$set": bson.M{
				"equipped_items": user.EquippedItems,
				"stats":          user.Stats,
				"updated_at":     time.Now(),
			},
		}

		result, err := userCollection.UpdateOne(ctx, bson.M{"_id": userOID}, update)
		if err != nil {
			logger.Errorf("Failed to update user: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to unequip item"})
			return
		}

		if result.MatchedCount == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"message": "Item unequipped successfully",
			"item_id": itemID,
			"slot":    req.Slot,
			"stats":   user.Stats,
		})
	}
}

func AddStatsWithSkillPoints() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 1. Retrieve the authenticated user ID from the context.
		userID := c.GetString("id")
		if userID == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID not found in context"})
			return
		}

		// 2. Get the 'stat' and 'points' parameters from the URL.
		stat := c.Param("stat")
		pointsStr := c.Param("points")
		if stat == "" || pointsStr == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "both stat and points parameters are required"})
			return
		}

		// 3. Normalize and validate the stat parameter.
		stat = strings.ToLower(stat)
		switch stat {
		case "vitality", "strength", "endurance", "agility":
			// valid stat; continue processing
		default:
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid stat. Must be one of: vitality, strength, endurance, agility"})
			return
		}

		// 4. Convert the points parameter to an integer.
		points, err := strconv.Atoi(pointsStr)
		if err != nil || points <= 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "points must be a positive integer"})
			return
		}

		// 5. Convert the userID string to a BSON ObjectID.
		userOID, err := bson.ObjectIDFromHex(userID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
			return
		}

		// 6. Get the database collection and prepare a context.
		collection := database.Users()
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		// 7. Fetch the user document.
		var user models.User
		err = collection.FindOne(ctx, bson.M{"_id": userOID}).Decode(&user)
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
			return
		}

		// 8. Verify that the user has enough skill points.
		if user.SkillPoints < points {
			c.JSON(http.StatusBadRequest, gin.H{
				"error":     "insufficient skill points",
				"available": user.SkillPoints,
			})
			return
		}

		// 9. Prepare the update: add points to the chosen stat and subtract those points from available skill points.
		update := bson.M{
			"$inc": bson.M{
				"stats." + stat: points,
				"skill_points":  -points,
			},
		}

		// 10. Execute the update.
		updateResult, err := collection.UpdateOne(ctx, bson.M{"_id": userOID}, update) // Renamed result to updateResult
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update stats", "details": err.Error()})
			return
		}
		if updateResult.ModifiedCount == 0 { // Used updateResult
			c.JSON(http.StatusInternalServerError, gin.H{"error": "no changes were made; please check the request"})
			return
		}

		// 11. Return a success response.
		c.JSON(http.StatusOK, gin.H{
			"message": fmt.Sprintf("Successfully added %d point(s) to %s", points, stat),
		})
	}
}

// GetUserInventoryItems retrieves the items present in the logged-in user's inventory
func GetUserInventoryItems() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get user ID from context
		userIDStr := c.GetString("id")
		if userIDStr == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID not found in context"})
			return
		}

		userOID, err := bson.ObjectIDFromHex(userIDStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID format"})
			return
		}

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		// Get user to find their inventory ID
		userCollection := database.Users()
		var user models.User
		err = userCollection.FindOne(ctx, bson.M{"_id": userOID}).Decode(&user)
		if err != nil {
			if err == mongo.ErrNoDocuments {
				c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
			} else {
				logger.Errorf("Database error retrieving user: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to retrieve user"})
			}
			return
		}

		// Check if user has an inventory ID
		if user.InventoryID.IsZero() {
			c.JSON(http.StatusNotFound, gin.H{"error": "user does not have an inventory assigned"})
			return
		}

		// Get the inventory using the InventoryID
		inventoryCollection := database.Inventories()
		var inventory models.Inventory
		err = inventoryCollection.FindOne(ctx, bson.M{"_id": user.InventoryID}).Decode(&inventory)
		if err != nil {
			if err == mongo.ErrNoDocuments {
				c.JSON(http.StatusNotFound, gin.H{"error": "inventory not found"})
			} else {
				logger.Errorf("Database error retrieving inventory: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to retrieve inventory"})
			}
			return
		}

		// Check if the inventory has any items
		if len(inventory.Items) == 0 {
			c.JSON(http.StatusOK, gin.H{"items": []models.Item{}}) // Return empty list
			return
		}

		// Fetch the details of the items in the inventory
		itemsCollection := database.Items()
		filter := bson.M{"_id": bson.M{"$in": inventory.Items}}
		cursor, err := itemsCollection.Find(ctx, filter)
		if err != nil {
			logger.Errorf("Database error retrieving inventory items: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to retrieve inventory items"})
			return
		}
		defer cursor.Close(ctx)

		var items []models.Item
		if err = cursor.All(ctx, &items); err != nil {
			logger.Errorf("Failed to decode inventory items: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to process inventory items"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"items": items})
	}
}
