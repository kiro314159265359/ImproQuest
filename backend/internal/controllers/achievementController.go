package controllers

import (
	"context"
	"net/http"
	"time"

	"github.com/HarDizzeR/Project/backend/internal/database"
	"github.com/HarDizzeR/Project/backend/internal/helpers"
	"github.com/HarDizzeR/Project/backend/internal/models"
	"github.com/gin-gonic/gin"

	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
)

func CreateAchievement(c *gin.Context) {
	if err := helpers.CheckUserType(c, "Admin"); err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "unauthorized access"})
		return
	}

	var achievement models.Achievement
	if err := c.BindJSON(&achievement); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := validate.Struct(achievement); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	achievement.ID = bson.NewObjectID()

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	achievementsCollection := database.Achievements()
	result, err := achievementsCollection.InsertOne(ctx, achievement)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to create achievement"})
		return
	}

	c.JSON(http.StatusCreated, result)
}

func GetAllAchievements(c *gin.Context) {
	if err := helpers.CheckUserType(c, "Admin"); err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "unauthorized access"})
		return
	}

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
	if err := helpers.CheckUserType(c, "Admin"); err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "unauthorized access"})
		return
	}

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
	if err := helpers.CheckUserType(c, "Admin"); err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "unauthorized access"})
		return
	}

	id := c.Param("id")
	objID, err := bson.ObjectIDFromHex(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid achievement ID"})
		return
	}

	var updateData models.Achievement
	if err := c.ShouldBindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := validate.Struct(updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	update := bson.M{
		"$set": bson.M{
			"name":        updateData.Name,
			"description": updateData.Description,
			"reward":      updateData.Reward,
			"date_earned": updateData.DateEarned,
		},
	}

	achievementsCollection := database.Achievements()
	result, err := achievementsCollection.UpdateOne(ctx, bson.M{"_id": objID}, update)
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

func DeleteAchievement(c *gin.Context) {
	if err := helpers.CheckUserType(c, "Admin"); err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "unauthorized access"})
		return
	}

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
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to delete achievement"})
		return
	}

	if result.DeletedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "achievement not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "achievement deleted successfully"})
}

func AddAchievement(c *gin.Context) {
	// Get user ID from context
	userID := c.GetString("id")
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User ID not found in context"})
		return
	}

	// Get achievement ID from URL parameter
	achievementIDParam := c.Param("achievement_id")
	achievementID, err := bson.ObjectIDFromHex(achievementIDParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid achievement ID"})
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Check if the achievement exists
	achievementCollection := database.Achievements()
	var existingAchievement models.Achievement
	err = achievementCollection.FindOne(ctx, bson.M{"_id": achievementID}).Decode(&existingAchievement)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "Achievement not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Convert user ID to ObjectID
	userObjID, err := bson.ObjectIDFromHex(userID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	// Update the user's Achievements array to include the new achievement ID
	userCollection := database.Users()
	update := bson.M{
		"$set": bson.M{
			"achievements": bson.M{
				"$cond": bson.M{
					"if":   bson.M{"$isArray": "$achievements"},
					"then": bson.M{"$concatArrays": bson.A{"$achievements", bson.A{achievementID}}},
					"else": bson.A{achievementID},
				},
			},
			"updated_at": time.Now(),
		},
	}

	_, err = userCollection.UpdateByID(ctx, userObjID, update)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user", "msg": err})

		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Achievement added successfully"})
}

func RemoveAchievement(c *gin.Context) {
	// Get parameters from context and path
	userIDStr := c.GetString("id")
	achievementIDStr := c.Param("achievement_id")

	// Validate input
	if userIDStr == "" || achievementIDStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing user ID or achievement ID"})
		return
	}

	// Convert user ID string to ObjectID
	userID, err := bson.ObjectIDFromHex(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID format"})
		return
	}

	// Convert achievement ID string to ObjectID
	achievementID, err := bson.ObjectIDFromHex(achievementIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid achievement ID format"})
		return
	}

	// Get database collection
	collection := database.Users()
	ctx := context.Background()

	// Create filter for user
	filter := bson.M{"_id": userID}

	// First check if achievement exists in user's array
	var user models.User
	err = collection.FindOne(ctx, filter).Decode(&user)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Check if achievement exists in the array
	exists := false
	for _, ach := range user.Achievements {
		if ach == achievementID {
			exists = true
			break
		}
	}

	if !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "Achievement not found for this user"})
		return
	}

	// Create update to remove achievement
	update := bson.M{
		"$pull": bson.M{"achievements": achievementID},
	}

	// Perform update operation
	_, err = collection.UpdateOne(ctx, filter, update)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to remove achievement"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Achievement removed successfully"})
}
