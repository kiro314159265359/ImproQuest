package controllers

import (
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"

	"github.com/HarDizzeR/Project/backend/internal/database"
	"github.com/HarDizzeR/Project/backend/internal/helpers"
	"github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/HarDizzeR/Project/backend/internal/models"
)

func AddItem(c *gin.Context) {
	userID := c.GetString("id")
	itemIDParam := c.Param("itemId")

	// Convert IDs to ObjectIDs (existing code remains same)
	userObjID, err := bson.ObjectIDFromHex(userID)
	if err != nil {
		// ... error handling
	}

	itemObjID, err := bson.ObjectIDFromHex(itemIDParam)
	if err != nil {
		// ... error handling
	}

	// Get full item details (existing code remains same)
	ctx := context.TODO()
	var item models.Item
	itemsCollection := database.Items()
	err = itemsCollection.FindOne(ctx, bson.M{"_id": itemObjID}).Decode(&item)
	if err != nil {
		// ... error handling
	}

	// Atomic update to add item only if not exists
	filter := bson.M{
		"_id":       userObjID,
		"items._id": bson.M{"$ne": itemObjID}, // Check if item not already exists
	}

	update := bson.M{
		"$push": bson.M{
			"items": item, // Push full item document
		},
	}

	result, err := userCollection.UpdateOne(ctx, filter, update)
	if err != nil {
		logger.Errorf("Failed to update user: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add item"})
		return
	}

	// Handle different cases
	if result.MatchedCount == 0 {
		// Check if user exists
		var user models.User
		err := userCollection.FindOne(ctx, bson.M{"_id": userObjID}).Decode(&user)
		if err != nil {
			if err == mongo.ErrNoDocuments {
				logger.Errorf("User not found: %v", userObjID)
				c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
				return
			}
			logger.Errorf("Database error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal error"})
			return
		}

		// User exists but item already in inventory
		c.JSON(http.StatusOK, gin.H{"message": "Item already exists in inventory"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Item added successfully",
		"item":    item,
	})
}

func RemoveItem(c *gin.Context) {
	// Get user ID from context
	userID := c.GetString("id")
	itemIDParam := c.Param("itemId")

	// Convert userID to ObjectID
	userObjID, err := bson.ObjectIDFromHex(userID)
	if err != nil {
		logger.Errorf("Invalid user ID format: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID format"})
		return
	}

	// Convert itemID from URL parameter to ObjectID
	itemObjID, err := bson.ObjectIDFromHex(itemIDParam)
	if err != nil {
		logger.Errorf("Invalid item ID format: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item ID format"})
		return
	}

	// Update user's items array to remove the item
	filter := bson.M{"_id": userObjID}
	update := bson.M{"$pull": bson.M{"items": itemObjID}}

	result, err := userCollection.UpdateOne(context.TODO(), filter, update)
	if err != nil {
		logger.Errorf("Failed to update user: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to remove item from user"})
		return
	}

	if result.MatchedCount == 0 {
		logger.Errorf("User not found: %v", userObjID)
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	if result.ModifiedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Item not found in user's collection"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Item removed successfully"})
}

func CreateItem(c *gin.Context) {
	// Verify admin privileges
	err := helpers.CheckUserType(c, "Admin")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Parse request body
	var item models.Item
	if err := c.ShouldBindJSON(&item); err != nil {
		logger.Errorf("Invalid request body: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}
	// Generate new ID and validate
	item.ID = bson.NewObjectID()
	if err := validate.Struct(item); err != nil {
		logger.Errorf("Validation failed: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Insert into database
	ctx := context.TODO()
	itemsCollection := database.Items()
	_, err = itemsCollection.InsertOne(ctx, item)
	if err != nil {
		logger.Errorf("Failed to create item: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create item"})
		return
	}

	c.JSON(http.StatusCreated, item)
}
func UpdateItem(c *gin.Context) {
	// Verify admin privileges
	if err := helpers.CheckUserType(c, "Admin"); err != nil {
		logger.Warn("Unauthorized update attempt")
		c.JSON(http.StatusForbidden, gin.H{"error": "Unauthorized access"})
		return
	}

	// Get item ID from URL
	itemIDParam := c.Param("itemId")
	itemObjID, err := bson.ObjectIDFromHex(itemIDParam)
	if err != nil {
		logger.Errorf("Invalid item ID: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item ID"})
		return
	}

	// Parse request body
	var updateData models.Item
	if err := c.ShouldBindJSON(&updateData); err != nil {
		logger.Errorf("Invalid request body: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	// Force use URL ID and validate
	updateData.ID = itemObjID
	if err := validate.Struct(updateData); err != nil {
		logger.Errorf("Validation failed: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Update in database
	ctx := context.TODO()
	filter := bson.M{"_id": itemObjID}
	update := bson.M{"$set": updateData}

	itemsCollection := database.Items()
	result, err := itemsCollection.UpdateOne(ctx, filter, update)
	if err != nil {
		logger.Errorf("Update failed: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update item"})
		return
	}

	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Item not found"})
		return
	}

	c.JSON(http.StatusOK, updateData)
}
