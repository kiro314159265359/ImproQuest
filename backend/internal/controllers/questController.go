package controllers

import (
	"context"

	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"

	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
	"go.mongodb.org/mongo-driver/v2/mongo/options"

	"github.com/HarDizzeR/Project/backend/internal/database"
	"github.com/HarDizzeR/Project/backend/internal/helpers"
	"github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/HarDizzeR/Project/backend/internal/models"
	"github.com/HarDizzeR/Project/backend/internal/services"
)

var questCollection *mongo.Collection = database.Quests()

type QuestRequest struct {
	Name       *string  `json:"Name" validate:"required,min=3,max=100"`
	XPReward   *float64 `json:"XPReward" validate:"required,gte=0"`
	GoldReward *float64 `json:"GoldReward" validate:"required,gte=0"`
	Goal       *float64 `json:"goal" bson:"goal"`
	Type       *string  `json:"type" bson:"type" validate:"required,oneof=Running Mental Habit"`
}

type UpdateMentalHabitQuestRequest struct {
	Name       *string  `json:"name,omitempty" validate:"omitempty,min=3,max=100"`
	Type       *string  `json:"type,omitempty" bson:"type,omitempty" validate:"omitempty,gte=0"`
	XPReward   *float64 `json:"xp_reward,omitempty" bson:"xp_reward,omitempty" validate:"omitempty,gte=0"`
	GoldReward *float64 `json:"gold_reward,omitempty" bson:"gold_reward,omitempty" validate:"omitempty,gte=0"`
}

// Create Quest

func CreateQuest() gin.HandlerFunc {
	return func(c *gin.Context) {

		var questReq QuestRequest

		// Bind the incoming JSON to questReq
		if err := c.ShouldBindJSON(&questReq); err != nil {
			logger.Errorf("Invalid Request Format: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		if err := validate.Struct(questReq); err != nil {
			var validationErrors []string
			for _, err := range err.(validator.ValidationErrors) {
				validationErrors = append(validationErrors, fmt.Sprintf("%s: %s", err.Field(), err.Tag()))
			}
			logger.Errorf("Validation error: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"errors": validationErrors})
			return
		}

		quest := models.Quest{
			Name:       questReq.Name,
			XPReward:   questReq.XPReward,
			Goal:       questReq.Goal,
			GoldReward: questReq.GoldReward,
			Type:       questReq.Type,
		}

		quest.ID = bson.NewObjectID()
		quest.IsCompleted = false

		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		_, err := questCollection.InsertOne(ctx, quest)
		if err != nil {
			logger.Errorf("Error while creating Quest: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		c.JSON(http.StatusCreated, quest)
	}
}

// Get all Quests with pagination

func GetQuests() gin.HandlerFunc {
	return func(c *gin.Context) {
		var quests []models.Quest
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		cursor, err := questCollection.Find(ctx, bson.M{})
		if err != nil {
			logger.Errorf("Error while fetching Quests: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		if err = cursor.All(ctx, &quests); err != nil {
			logger.Errorf("Error while decoding Quests: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		c.JSON(http.StatusOK, gin.H{"length": len(quests), "quests": quests})
	}
}

// Get Quest by ID

func GetQuest() gin.HandlerFunc {
	return func(c *gin.Context) {
		questID := c.Param("id")
		objectID, err := bson.ObjectIDFromHex(questID)
		if err != nil {
			logger.Errorf("Invalid quest ID format: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid quest ID format"})
			return
		}

		var quest models.Quest
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		err = questCollection.FindOne(ctx, bson.M{"_id": objectID}).Decode(&quest)
		if err != nil {
			logger.Errorf("Error while fetching Quest: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		c.JSON(http.StatusOK, quest)
	}
}

// Update Quest

func UpdateQuest() gin.HandlerFunc {
	return func(c *gin.Context) {

		questID := c.Param("id")
		objectID, err := bson.ObjectIDFromHex(questID)
		if err != nil {
			logger.Errorf("Invalid quest ID format: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid quest ID format"})
			return
		}

		var updateData bson.M
		if err := c.ShouldBindJSON(&updateData); err != nil {
			logger.Errorf("Invalid Request Format: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		update := bson.M{"$set": updateData}
		result, err := questCollection.UpdateOne(ctx, bson.M{"_id": objectID}, update)
		if err != nil {
			logger.Errorf("Error while updating Quest: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		if result.MatchedCount == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "Quest not found"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Quest updated successfully", "modified_count": result.ModifiedCount})
	}
}

// Delete Quest

func DeleteQuest() gin.HandlerFunc {
	return func(c *gin.Context) {

		questID := c.Param("id")
		objectID, err := bson.ObjectIDFromHex(questID)
		if err != nil {
			logger.Errorf("Invalid quest ID format: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid quest ID format"})
			return
		}

		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		result, err := questCollection.DeleteOne(ctx, bson.M{"_id": objectID})
		if err != nil {
			logger.Errorf("Error while deleting Quest: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		if result.DeletedCount == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "Quest not found"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Quest deleted successfully"})
	}
}

func CompleteQuest() gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.GetString("id")
		if userID == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID not found in context"})
			return
		}

		questID := c.Param("questId")
		if questID == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "quest ID is required"})
			return
		}

		// Convert IDs
		userOID, err := bson.ObjectIDFromHex(userID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
			return
		}

		questOID, err := bson.ObjectIDFromHex(questID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid quest ID"})
			return
		}

		// Get database collection
		collection := database.Users()
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		// 1. Fetch user document
		var user models.User
		err = collection.FindOne(ctx, bson.M{"_id": userOID}).Decode(&user)
		if helpers.HandleError(c, err) {
			return
		}

		// 2. Find the quest in user's "quests" array
		var quest *models.Quest
		for i := range user.CurrentQuests {
			if user.CurrentQuests[i].ID.Hex() == questOID.Hex() {
				quest = &user.CurrentQuests[i]
				break
			}
		}
		if quest == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "quest not found"})
			return
		}
		if quest.IsCompleted {
			c.JSON(http.StatusBadRequest, gin.H{"error": "quest already completed"})
			return
		}

		if !quest.IsCustom {
			if time.Now().After(quest.GivenAt.Add(24 * time.Hour)) {
				c.JSON(http.StatusBadRequest, gin.H{"error": "quest expired; complete within 24 hours"})
				return
			}
		}

		if quest.XPReward == nil || quest.GoldReward == nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "invalid quest rewards"})
			return
		}

		// 3. Update user to award XP/gold & mark quest as completed
		now := time.Now()
		filter := bson.M{
			"_id": userOID,
		}
		update := bson.M{
			"$inc": bson.M{
				"xp":                     *quest.XPReward,
				"gold":                   *quest.GoldReward,
				"completed_quests_count": 1, // Increment completed quests count
			},
			"$set": bson.M{
				"quests.$[elem].is_completed": true,
				"quests.$[elem].completed_at": now, // Record completion time
				"updated_at":                  now,
			},
		}

		// Define the array filter to match only the quest with the specified ID.
		opts := options.UpdateOne().
			SetArrayFilters([]any{
				bson.D{{Key: "elem._id", Value: questOID}},
			})

		result, err := collection.UpdateOne(ctx, filter, update, opts)
		if helpers.HandleError(c, err) {
			return
		}
		if result.ModifiedCount == 0 {
			c.JSON(http.StatusConflict, gin.H{"error": "quest completion failed or already completed"})
			return
		}

		// 4. Fetch updated user to get the new XP total and other stats for achievement check
		err = collection.FindOne(ctx, bson.M{"_id": userOID}).Decode(&user)
		if helpers.HandleError(c, err) {
			return
		}

		// 5. Level-up check and rank update
		levelUps := 0
		for {
			threshold := helpers.XpThresholdForLevel(user.Level)
			// Ensure threshold > 0 to avoid infinite loops
			if user.XP >= threshold && threshold > 0 {
				user.XP -= threshold
				user.Level++
				levelUps++
			} else {
				break
			}
		}

		if levelUps > 0 {
			newRank := helpers.GetRankForLevel(user.Level)
			const pointsPerLevel = 5

			updateFields := bson.M{
				"xp":    user.XP,
				"level": user.Level,
				"rank":  newRank,
			}
			updateRankAndPoints := bson.M{
				"$set": updateFields,
				"$inc": bson.M{"skillpoints": pointsPerLevel},
			}

			_, err := collection.UpdateOne(ctx, bson.M{"_id": userOID}, updateRankAndPoints)
			if helpers.HandleError(c, err) {
				return
			}
			user.Rank = newRank

		}
		if levelUps > 0 {
			err = collection.FindOne(ctx, bson.M{"_id": userOID}).Decode(&user)
			if helpers.HandleError(c, err) {
				return
			}
		}
		// Check for achievements after all updates
		go services.AwardAchievements(context.Background(), userOID) // Run in a goroutine if it can be slow

		// 6. Send response
		c.JSON(http.StatusOK, gin.H{
			"message":       "Quest completed!",
			"xp_gained":     *quest.XPReward,
			"gold_gained":   *quest.GoldReward,
			"new_level":     user.Level,
			"current_xp":    user.XP,
			"levels_gained": levelUps,
			"new_rank":      user.Rank,
		})
	}
}

func UpdateStreakHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 1. Get user id from context
		userID := c.GetString("id")
		if userID == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found in context"})
			return
		}

		// Convert the userID to an ObjectID
		userOID, err := bson.ObjectIDFromHex(userID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
			return
		}

		// 2. Fetch the user from the database
		collection := database.Users() // Assume your database package exposes a Users() collection.
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		var user models.User
		if err := collection.FindOne(ctx, bson.M{"_id": userOID}).Decode(&user); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "User not found"})
			return
		}

		// 3. Check if all quests are completed using the helper
		if !helpers.AreAllQuestsCompleted(user.CurrentQuests) {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Not all quests are completed"})
			return
		}

		// 4. Update the streak if the quests are all done
		currentTime := time.Now()
		today := currentTime.Truncate(24 * time.Hour)
		yesterday := today.AddDate(0, 0, -1)

		// Update the streak only if not already updated today.
		if user.Streak.LastCompleted.IsZero() || !helpers.SameDay(user.Streak.LastCompleted, today) {
			if helpers.SameDay(user.Streak.LastCompleted, yesterday) {
				user.Streak.Current++ // Increment streak if completed yesterday
			} else {
				user.Streak.Current = 0 // Reset streak if a day was skipped
			}
			user.Streak.LastCompleted = today

			// Optionally, update the highest streak record if you maintain a count.
			if user.Streak.Current > user.Streak.HighestCount {
				user.Streak.HighestCount = user.Streak.Current
			}
		}

		// 5. Save the updated streak back to the database
		update := bson.M{"$set": bson.M{"streak": user.Streak, "updated_at": time.Now()}}
		_, err = collection.UpdateOne(ctx, bson.M{"_id": userOID}, update)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update streak"})
			return
		}

		// Check for achievements after streak update
		go services.AwardAchievements(context.Background(), userOID) // Run in a goroutine

		// 6. Respond with success and the updated streak information
		c.JSON(http.StatusOK, gin.H{
			"message": "Streak updated successfully",
			"streak":  user.Streak,
		})
	}
}

func EditMentalOrHabitQuest() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 1. Get user ID from token/context
		userIDStr := c.GetString("id")
		if userIDStr == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized: missing user ID"})
			return
		}
		userOID, err := bson.ObjectIDFromHex(userIDStr)
		if err != nil {
			logger.Errorf("Invalid user ID format for edit: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID format"})
			return
		}

		// 2. Parse quest ID
		questIDStr := c.Param("id")
		questOID, err := bson.ObjectIDFromHex(questIDStr)
		if err != nil {
			logger.Errorf("Invalid quest ID format for edit: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid quest ID format"})
			return
		}

		// 3. Bind & validate input
		var upd UpdateMentalHabitQuestRequest
		if err := c.ShouldBindJSON(&upd); err != nil {
			logger.Errorf("Invalid Request Format for editing quest: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		if err := validate.Struct(upd); err != nil {
			var errs []string
			for _, e := range err.(validator.ValidationErrors) {
				errs = append(errs, fmt.Sprintf("Field '%s': validation '%s' failed", e.Field(), e.Tag()))
			}
			c.JSON(http.StatusBadRequest, gin.H{"errors": errs})
			return
		}

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		userCollection := database.Users()

		// 4. Fetch user and verify quest ownership, type, and custom status
		var user models.User
		err = userCollection.FindOne(ctx, bson.M{"_id": userOID}).Decode(&user)
		if err != nil {
			if err == mongo.ErrNoDocuments {
				c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
			} else {
				logger.Errorf("Failed to retrieve user: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve user"})
			}
			return
		}

		var existingQuest *models.Quest
		for i, q := range user.CurrentQuests {
			if q.ID == questOID {
				existingQuest = &user.CurrentQuests[i]
				break
			}
		}

		if existingQuest == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Quest not found in user's list"})
			return
		}

		if !existingQuest.IsCustom {
			c.JSON(http.StatusForbidden, gin.H{"error": "Cannot edit a non-custom quest"})
			return
		}
		if existingQuest.Type == nil || (*existingQuest.Type != "Mental" && *existingQuest.Type != "Habit") {
			c.JSON(http.StatusForbidden, gin.H{"error": fmt.Sprintf("Cannot edit a '%s' quest via this endpoint", ptrToString(existingQuest.Type))})
			return
		}

		// 5. Build update document for the specific quest in the array
		updateFields := bson.M{}
		if upd.Name != nil {
			updateFields["quests.$[elem].name"] = *upd.Name
		}
		if upd.Type != nil {
			updateFields["quests.$[elem].type"] = *upd.Type
		}
		if upd.XPReward != nil {
			updateFields["quests.$[elem].xp_reward"] = *upd.XPReward
		}
		if upd.GoldReward != nil {
			updateFields["quests.$[elem].gold_reward"] = *upd.GoldReward
		}

		if len(updateFields) == 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "No fields to update"})
			return
		}

		// 6. Perform update on the user document
		filter := bson.M{"_id": userOID}
		// Use options.UpdateOne() and pass the slice of filters directly to SetArrayFilters.
		opts := options.UpdateOne().
			SetArrayFilters([]interface{}{
				bson.D{
					{Key: "elem._id", Value: questOID},
					{Key: "elem.is_custom", Value: true},
					{Key: "elem.type", Value: bson.D{{Key: "$in", Value: []string{"Mental", "Habit"}}}},
				},
			})

		result, err := userCollection.UpdateOne(
			ctx,
			filter,
			bson.D{{Key: "$set", Value: updateFields}},
			opts,
		)
		if err != nil {
			logger.Errorf("Failed to update quest in user document: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update quest"})
			return
		}

		if result.MatchedCount == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "Quest not found or does not meet update criteria"})
			return
		}

		if result.ModifiedCount == 0 {
			c.JSON(http.StatusOK, gin.H{"message": "No changes were made to the quest", "quest_id": questIDStr})
			return
		}

		// 7. Return updated quest (fetch user again to get the modified quest data)
		var updatedUser models.User
		err = userCollection.FindOne(ctx, bson.M{"_id": userOID}).Decode(&updatedUser)
		if err != nil {
			logger.Errorf("Failed to retrieve updated user data: %v", err)
			c.JSON(http.StatusOK, gin.H{"message": "Quest updated successfully, but failed to retrieve updated quest details", "quest_id": questIDStr})
			return
		}

		for _, q := range updatedUser.CurrentQuests {
			if q.ID == questOID {
				c.JSON(http.StatusOK, gin.H{"message": "Quest updated successfully", "quest": q})
				return
			}
		}

		c.JSON(http.StatusOK, gin.H{"message": "Quest updated successfully, but could not find it in user's list post-update", "quest_id": questIDStr})
	}
}

func DeleteMentalOrHabitQuest() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 1. Get user ID
		userIDStr := c.GetString("id")
		if userIDStr == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized: missing user ID"})
			return
		}
		userOID, err := bson.ObjectIDFromHex(userIDStr)
		if err != nil {
			logger.Errorf("Invalid user ID format for delete: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID format"})
			return
		}

		// 2. Parse quest ID
		questIDStr := c.Param("id")
		questOID, err := bson.ObjectIDFromHex(questIDStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid quest ID format"})
			return
		}

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		userCollection := database.Users()

		// 3. Fetch user to verify quest existence and properties before deletion
		var user models.User
		err = userCollection.FindOne(ctx, bson.M{"_id": userOID}).Decode(&user)
		if err != nil {
			if err == mongo.ErrNoDocuments {
				c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
			} else {
				logger.Errorf("Failed to retrieve user for quest deletion: %v", err)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve user information"})
			}
			return
		}

		var questToDelete *models.Quest
		for _, q := range user.CurrentQuests {
			if q.ID == questOID {
				questToDelete = &q
				break
			}
		}

		if questToDelete == nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Quest not found in user's list"})
			return
		}
		if !questToDelete.IsCustom {
			c.JSON(http.StatusForbidden, gin.H{"error": "Cannot delete a non-custom quest"})
			return
		}
		if questToDelete.Type == nil || (*questToDelete.Type != "Mental" && *questToDelete.Type != "Habit") {
			c.JSON(http.StatusForbidden, gin.H{"error": fmt.Sprintf("Cannot delete a '%s' quest via this endpoint", ptrToString(questToDelete.Type))})
			return
		}

		// 4. Delete quest from user's CurrentQuests array using $pull
		update := bson.M{
			"$pull": bson.M{
				"quests": bson.M{
					"_id":       questOID,
					"is_custom": true,                                       // Ensure it's a custom quest
					"type":      bson.M{"$in": []string{"Mental", "Habit"}}, // Ensure it's Mental or Habit
				},
			},
		}

		result, err := userCollection.UpdateOne(ctx, bson.M{"_id": userOID}, update)
		if err != nil {
			logger.Errorf("Failed to delete quest from user document: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete quest"})
			return
		}

		if result.ModifiedCount == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "Quest not found or not eligible for deletion"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Quest deleted successfully", "quest_id": questIDStr})
	}
}

func ptrToString(s *string) string {
	if s == nil {
		return ""
	}
	return *s
}
