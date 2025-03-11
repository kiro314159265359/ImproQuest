package controllers

import (
	"context"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"

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
		// Get user ID from context
		userId := c.GetString("id")

		// Convert string ID to ObjectID
		objId, err := bson.ObjectIDFromHex(userId)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
			return
		}

		// Get MongoDB collection
		collection := database.Users()

		// Find user in database
		var user models.User
		err = collection.FindOne(c.Request.Context(), bson.M{"_id": objId}).Decode(&user)
		if err != nil {
			if err == mongo.ErrNoDocuments {
				c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch user data"})
			return
		}
		// Directly return the user struct with sensitive fields omitted
		c.JSON(http.StatusOK, user)
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

		err = userCollection.FindOne(ctx, bson.M{"_id": id}).Decode(&user)

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		if err := c.ShouldBindJSON(&user); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		var hashedPassword string
		if user.Password != nil {
			hashedPassword, err = helpers.HashPassword(*user.Password)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
				return
			}
		}

		user.Password = &hashedPassword
		user.Updated_at = time.Now()

		_, err = userCollection.ReplaceOne(ctx, bson.M{"_id": id}, user)
		if err != nil {
			logger.Errorf("Failed to update user %s: %v", userID, err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		logger.Infof("User updated successfully: %s", userID)
		c.JSON(http.StatusOK, gin.H{"message": "User was updated successfully", "user": user})
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

		// If quests are not null, check if the first quest's GivenAt has not passed its next 12AM.
		if len(user.CurrentQuests) > 0 {
			quest := user.CurrentQuests[0]
			// Get the current time in the same location as the quest's GivenAt
			now := time.Now().In(quest.GivenAt.Location())
			// Calculate today's midnight
			todayMidnight := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())

			// If the quest was assigned after today's midnight, it's still valid.
			if quest.GivenAt.After(todayMidnight) {
				fmt.Println("Quest is still valid, not assigning new one.")
				c.JSON(http.StatusOK, gin.H{"quest": user.CurrentQuests[0]})
				return
			}
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

		// Apply rank multiplier to rewards
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

		// Create a slice with just the one running quest
		selectedQuests := []models.Quest{runningQuest}

		// Update the user document to assign this quest
		filter := bson.M{"_id": objectID}
		update := bson.M{"$set": bson.M{"quests": selectedQuests}}
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
			"quest":      runningQuest,
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
			setValues["stats.agility"] = *updateData.Agility
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

func UpdateRunningQuestProgress() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get user ID from context (set by auth middleware)
		userID := c.GetString("id")
		if userID == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID not found in context"})
			return
		}

		// Parse request body
		var requestData struct {
			Progress float64 `json:"progress" binding:"required,gte=0"`
		}
		if err := c.ShouldBindJSON(&requestData); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request data: " + err.Error()})
			return
		}

		// Convert user ID to ObjectID
		userOID, err := bson.ObjectIDFromHex(userID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID format"})
			return
		}

		// Get database collections
		userCollection := database.Users()
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		// Find user and their quests
		var user models.User
		err = userCollection.FindOne(ctx, bson.M{"_id": userOID}).Decode(&user)
		if err != nil {
			if err == mongo.ErrNoDocuments {
				c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
			} else {
				logger.Errorf("Error fetching user: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "database error"})
			}
			return
		}

		// Check if user has any quests
		if len(user.CurrentQuests) == 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "user has no active quests"})
			return
		}

		// Find the running quest
		var runningQuest *models.Quest
		for i, quest := range user.CurrentQuests {
			if quest.Type != nil && *quest.Type == "Running" {
				runningQuest = &user.CurrentQuests[i]
				break
			}
		}

		if runningQuest == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "no running quest found"})
			return
		}

		// Check if quest is already completed
		if runningQuest.IsCompleted {
			c.JSON(http.StatusBadRequest, gin.H{"error": "quest is already completed"})
			return
		}

		// Update progress
		progress := requestData.Progress
		runningQuest.Progress = &progress

		// Check if quest goal has been met and set as completed if so
		if runningQuest.Goal != nil && progress >= *runningQuest.Goal {
			runningQuest.Progress = runningQuest.Goal
			runningQuest.IsCompleted = true
		}

		// Update in database using the $ positional operator to update the specific quest in the array
		updateResult, err := userCollection.UpdateOne(
			ctx,
			bson.M{"_id": userOID, "quests._id": runningQuest.ID},
			bson.M{
				"$set": bson.M{
					"quests.$.progress":     progress,
					"quests.$.is_completed": runningQuest.IsCompleted,
				},
			},
		)

		if err != nil {
			logger.Errorf("Error updating quest progress: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update quest progress"})
			return
		}

		if updateResult.MatchedCount == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "quest not found"})
			return
		}

		// Return success response with updated quest
		c.JSON(http.StatusOK, gin.H{
			"message": "Quest progress updated successfully",
			"quest":   runningQuest,
		})
	}
}
