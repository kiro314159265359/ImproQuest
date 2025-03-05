package controllers

import (
	"context"
	"math/rand"
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

		var allQuests []models.Quest
		cursor, err := questCollection.Find(ctx, bson.M{})
		if err != nil {
			logger.Errorf("Error fetching quests: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch quests"})
			return
		}

		if err = cursor.All(ctx, &allQuests); err != nil {
			logger.Errorf("Error decoding quests: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode quests"})
			return
		}

		if len(allQuests) < 4 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Not enough quests available"})
			return
		}

		// Shuffle the quests using the global rand package
		rand.Seed(time.Now().UnixNano())
		rand.Shuffle(len(allQuests), func(i, j int) {
			allQuests[i], allQuests[j] = allQuests[j], allQuests[i]
		})

		// Select the first 4 quests
		selectedQuests := allQuests[:4]

		// Set the GivenAt field for each selected quest to the current time
		now := time.Now()
		for i := range selectedQuests {
			selectedQuests[i].GivenAt = now
		}

		// Update the user document to assign these quests
		filter := bson.M{"_id": objectID}
		update := bson.M{"$set": bson.M{"quests": selectedQuests}}
		updateResult, err := userCollection.UpdateOne(ctx, filter, update)
		if err != nil {
			logger.Errorf("Error updating user quests: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to assign quests"})
			return
		}

		if updateResult.MatchedCount == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"quests": selectedQuests})
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
