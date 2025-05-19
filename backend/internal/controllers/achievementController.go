package controllers

import (
	"context"
	"net/http"
	"time"

	"github.com/HarDizzeR/Project/backend/internal/database"
	"github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/HarDizzeR/Project/backend/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
)

var validateAchievement = validator.New()

func CreateAchievement(c *gin.Context) {
	var achievement models.Achievement
	if err := c.BindJSON(&achievement); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := validateAchievement.Struct(achievement); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	achievement.ID = bson.NewObjectID()
	// DateEarned is removed from the base achievement model

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	achievementsCollection := database.Achievements() // Use local var
	result, err := achievementsCollection.InsertOne(ctx, achievement)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to create achievement"})
		return
	}

	c.JSON(http.StatusCreated, result)
}

func GetAllAchievements(c *gin.Context) {

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	achievementsCollection := database.Achievements()
	cursor, err := achievementsCollection.Find(ctx, bson.M{})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch achievements"})
		return
	}
	defer cursor.Close(ctx)

	var achievements []models.Achievement
	if err := cursor.All(ctx, &achievements); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to decode achievements"})
		return
	}

	c.JSON(http.StatusOK, achievements)
}

func GetAchievementByID(c *gin.Context) {

	id := c.Param("id")
	objID, err := bson.ObjectIDFromHex(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid achievement ID"})
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var achievement models.Achievement
	achievementsCollection := database.Achievements()
	err = achievementsCollection.FindOne(ctx, bson.M{"_id": objID}).Decode(&achievement)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "achievement not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch achievement"})
		return
	}

	c.JSON(http.StatusOK, achievement)
}

func UpdateAchievement(c *gin.Context) {
	id := c.Param("id")
	objID, err := bson.ObjectIDFromHex(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid achievement ID"})
		return
	}

	var updateData models.Achievement // This will bind Name, Description, Reward, TriggerType, TriggerValue
	if err := c.ShouldBindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	updateFields := bson.M{}
	if updateData.Name != "" {
		updateFields["name"] = updateData.Name
	}
	if updateData.Description != "" {
		updateFields["description"] = updateData.Description
	}
	if updateData.Reward != "" {
		updateFields["reward"] = updateData.Reward
	}
	if updateData.TriggerType != "" {
		// Add validation for TriggerType if not covered by model tag during bind
		updateFields["trigger_type"] = updateData.TriggerType
	}

	updateFields["trigger_value"] = updateData.TriggerValue // This will set it even if 0.

	if len(updateFields) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "no fields to update"})
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	achievementsCollection := database.Achievements()
	result, err := achievementsCollection.UpdateOne(ctx, bson.M{"_id": objID}, bson.M{"$set": updateFields})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update achievement"})
		return
	}

	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "achievement not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "achievement updated successfully"})
}

func AddAchievement(c *gin.Context) { // Admin manually adds an achievement to a user
	userIDStr := c.GetString("id") // Assuming this is the target user ID from auth, or should be a param if admin targets other users
	if userIDStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User ID not found in context"})
		return
	}
	userObjID, err := bson.ObjectIDFromHex(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID format"})
		return
	}

	achievementIDParam := c.Param("achievement_id") // This should be achievement_id, not just "id" as per existing route
	achievementID, err := bson.ObjectIDFromHex(achievementIDParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid achievement ID"})
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	achievementsCollection := database.Achievements()
	var existingAchievement models.Achievement
	err = achievementsCollection.FindOne(ctx, bson.M{"_id": achievementID}).Decode(&existingAchievement)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "Achievement not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error fetching achievement"})
		return
	}

	userCollection := database.Users()
	// Check if user already has this achievement
	filter := bson.M{
		"_id":                             userObjID,
		"userachievements.achievement_id": achievementID,
	}
	count, err := userCollection.CountDocuments(ctx, filter)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error checking user achievements", "msg": err.Error()})
		return
	}
	if count > 0 {
		c.JSON(http.StatusConflict, gin.H{"error": "Achievement already earned by this user"})
		return
	}

	userEarnedAch := models.UserEarnedAchievement{
		AchievementID: achievementID,
		DateEarned:    time.Now(),
	}

	update := bson.M{
		"$push": bson.M{"userachievements": userEarnedAch},
		"$set":  bson.M{"updated_at": time.Now()},
	}

	_, err = userCollection.UpdateByID(ctx, userObjID, update) // UpdateByID might not be the correct method signature for mongo-driver
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user", "msg": err.Error()})
		return
	}

	// Using UpdateOne
	result, err := userCollection.UpdateOne(ctx, bson.M{"_id": userObjID}, update)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user", "msg": err.Error()})
		return
	}
	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Achievement added successfully to user"})
}

func RemoveAchievement(c *gin.Context) { // Admin manually removes an achievement from a user
	userIDStr := c.GetString("id")
	if userIDStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User ID not found in context"})
		return
	}
	userID, err := bson.ObjectIDFromHex(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID format"})
		return
	}

	achievementIDStr := c.Param("achievement_id")
	achievementID, err := bson.ObjectIDFromHex(achievementIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid achievement ID format"})
		return
	}

	userCollection := database.Users()
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Check if the achievement exists in the user's achievements array
	filterCheck := bson.M{"_id": userID, "userachievements.achievement_id": achievementID}
	count, err := userCollection.CountDocuments(ctx, filterCheck)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error", "msg": err.Error()})
		return
	}
	if count == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Achievement not found for this user"})
		return
	}

	update := bson.M{
		"$pull": bson.M{"userachievements": bson.M{"achievement_id": achievementID}},
		"$set":  bson.M{"updated_at": time.Now()},
	}
	resultUpdate, err := userCollection.UpdateOne(ctx, bson.M{"_id": userID}, update)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to remove achievement", "msg": err.Error()})
		return
	}
	if resultUpdate.ModifiedCount == 0 {
		// This could happen if the item was already removed or due to a race condition.
		// Or if MatchedCount was 1 but the $pull condition didn't match anything (should not happen if count > 0).
		c.JSON(http.StatusNotFound, gin.H{"error": "Achievement not found for this user or no changes made"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Achievement removed successfully from user"})
}

func DeleteAchievement(c *gin.Context) {
	id := c.Param("id")
	objID, err := bson.ObjectIDFromHex(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid achievement ID"})
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	achievementsCollection := database.Achievements()
	result, err := achievementsCollection.DeleteOne(ctx, bson.M{"_id": objID})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to delete achievement definition"})
		return
	}

	if result.DeletedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "achievement definition not found"})
		return
	}

	usersCollection := database.Users()
	_, err = usersCollection.UpdateMany(
		ctx,
		bson.M{"userachievements.achievement_id": objID}, // Filter for users who have this achievement
		bson.M{"$pull": bson.M{"userachievements": bson.M{"achievement_id": objID}}},
	)
	if err != nil {
		// Log this error but don't necessarily fail the whole operation if deleting definition was main goal
		logger.Errorf("Failed to remove achievement %s from all users: %v", objID.Hex(), err)
		c.JSON(http.StatusInternalServerError, gin.H{"message": "achievement definition deleted, but failed to remove from some users", "error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "achievement deleted successfully and removed from users"})
}

// GetUserUnlockedAchievements returns achievements the current user has earned.
func GetUserUnlockedAchievements() gin.HandlerFunc {
	return func(c *gin.Context) {
		uid := c.GetString("id")
		if uid == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID missing"})
			return
		}
		userOID, err := bson.ObjectIDFromHex(uid)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
			return
		}

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		var user models.User
		if err := database.Users().
			FindOne(ctx, bson.M{"_id": userOID}).
			Decode(&user); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch user"})
			return
		}

		// nothing earned
		if len(user.UserAchievements) == 0 {
			c.JSON(http.StatusOK, []gin.H{})
			return
		}

		ids := make([]bson.ObjectID, len(user.UserAchievements))
		for i, ua := range user.UserAchievements {
			ids[i] = ua.AchievementID
		}

		cursor, err := database.Achievements().Find(ctx, bson.M{"_id": bson.M{"$in": ids}})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch achievements"})
			return
		}
		defer cursor.Close(ctx)

		var defs []models.Achievement
		if err := cursor.All(ctx, &defs); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to decode achievements"})
			return
		}

		// map defs by ID
		defMap := make(map[bson.ObjectID]models.Achievement, len(defs))
		for _, d := range defs {
			defMap[d.ID] = d
		}

		out := make([]gin.H, 0, len(user.UserAchievements))
		for _, ua := range user.UserAchievements {
			if d, ok := defMap[ua.AchievementID]; ok {
				out = append(out, gin.H{
					"achievement": d,
					"date_earned": ua.DateEarned,
				})
			}
		}
		c.JSON(http.StatusOK, out)
	}
}

// GetUserLockedAchievements returns achievements the current user has not yet earned.
func GetUserLockedAchievements() gin.HandlerFunc {
	return func(c *gin.Context) {
		uid := c.GetString("id")
		if uid == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "user ID missing"})
			return
		}
		userOID, err := bson.ObjectIDFromHex(uid)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID"})
			return
		}

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		var user models.User
		if err := database.Users().
			FindOne(ctx, bson.M{"_id": userOID}).
			Decode(&user); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch user"})
			return
		}

		earned := make(map[bson.ObjectID]struct{}, len(user.UserAchievements))
		for _, ua := range user.UserAchievements {
			earned[ua.AchievementID] = struct{}{}
		}

		cursor, err := database.Achievements().Find(ctx, bson.M{})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch achievements"})
			return
		}
		defer cursor.Close(ctx)

		var all []models.Achievement
		if err := cursor.All(ctx, &all); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to decode achievements"})
			return
		}

		locked := make([]models.Achievement, 0, len(all))
		for _, a := range all {
			if _, ok := earned[a.ID]; !ok {
				locked = append(locked, a)
			}
		}
		c.JSON(http.StatusOK, locked)
	}
}
