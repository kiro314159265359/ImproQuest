package controllers

import (
	"net/http"

	"github.com/HarDizzeR/Project/backend/internal/database"
	"github.com/HarDizzeR/Project/backend/internal/models"
	"github.com/gin-gonic/gin"

	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
)

func AddInventory(c *gin.Context) {
	// Get user ID from URL params
	userID := c.Param("id")
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User ID is required"})
		return
	}

	// Convert to ObjectID
	objID, err := bson.ObjectIDFromHex(userID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID format"})
		return
	}

	// Check if inventory already exists for this user
	collection := database.Inventories()
	var existingInventory models.Inventory
	err = collection.FindOne(c, bson.M{"user_id": objID}).Decode(&existingInventory)
	if err == nil {
		// If inventory exists, return an error
		c.JSON(http.StatusConflict, gin.H{"error": "User already has an inventory"})
		return
	} else if err != mongo.ErrNoDocuments {
		// If there's a database error (not just no documents), return an internal server error
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Bind directly to Inventory model
	var inventory models.Inventory
	if err := c.ShouldBindJSON(&inventory); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Set user ID from URL param (override any body input)
	inventory.UserID = objID

	// Initialize empty arrays if not provided
	if inventory.Items == nil {
		inventory.Items = []bson.ObjectID{}
	}
	if inventory.Gear == nil {
		inventory.Gear = []bson.ObjectID{}
	}

	// Validate the inventory struct
	if err := validate.Struct(inventory); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Insert into database
	collection = database.Inventories()
	result, err := collection.InsertOne(c, inventory)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create inventory"})
		return
	}

	// Type assertion safety check
	if oid, ok := result.InsertedID.(bson.ObjectID); ok {
		inventory.ID = oid
	} else {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Type assertion failed for inserted ID"})
		return
	}

	c.JSON(http.StatusCreated, inventory)
}

func GetAllInventories(c *gin.Context) {
	collection := database.Inventories()
	cursor, err := collection.Find(c, bson.M{})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch inventories"})
		return
	}
	defer cursor.Close(c)

	var inventories []models.Inventory
	if err = cursor.All(c, &inventories); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse inventories"})
		return
	}

	c.JSON(http.StatusOK, inventories)
}

func GetInventoryByID(c *gin.Context) {
	inventoryID := c.Param("id")
	if inventoryID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Inventory ID is required"})
		return
	}

	objID, err := bson.ObjectIDFromHex(inventoryID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid inventory ID format"})
		return
	}

	collection := database.Inventories()
	var inventory models.Inventory
	err = collection.FindOne(c, bson.M{"_id": objID}).Decode(&inventory)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "Inventory not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		}
		return
	}

	c.JSON(http.StatusOK, inventory)
}

func DeleteInventoryByUserID(c *gin.Context) {
	userID := c.Param("id")
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User ID is required"})
		return
	}

	objID, err := bson.ObjectIDFromHex(userID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID format"})
		return
	}

	collection := database.Inventories()
	result, err := collection.DeleteOne(c, bson.M{"user_id": objID})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete inventory"})
		return
	}

	if result.DeletedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Inventory not found for the user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Inventory deleted successfully"})
}

func UpdateInventorySize(c *gin.Context) {
	inventoryID := c.Param("id")
	if inventoryID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Inventory ID is required"})
		return
	}

	objID, err := bson.ObjectIDFromHex(inventoryID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid inventory ID format"})
		return
	}

	// Parse request body
	var updateData struct {
		Size int `json:"size" bson:"size" validate:"required,gte=0"`
	}
	if err := c.ShouldBindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input: " + err.Error()})
		return
	}

	collection := database.Inventories()
	filter := bson.M{"_id": objID}
	update := bson.M{"$set": bson.M{"size": updateData.Size}}

	result, err := collection.UpdateOne(c, filter, update)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update inventory"})
		return
	}

	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Inventory not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Inventory size updated successfully"})
}
