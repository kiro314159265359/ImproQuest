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
	userObjID, err := bson.ObjectIDFromHex(userID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID format"})
		return
	}

	// Get user document to access InventoryID
	usersCollection := database.Users()
	var user models.User
	err = usersCollection.FindOne(c, bson.M{"_id": userObjID}).Decode(&user)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		}
		return
	}

	// Validate user has InventoryID
	if user.InventoryID.IsZero() {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User has no inventory ID assigned"})
		return
	}

	// Check if inventory already exists with this ID
	inventoryCollection := database.Inventories()
	var existingInventory models.Inventory
	err = inventoryCollection.FindOne(c, bson.M{"_id": user.InventoryID}).Decode(&existingInventory)
	if err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Inventory already exists for this user"})
		return
	} else if err != mongo.ErrNoDocuments {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Create new inventory with user's InventoryID as _id
	newInventory := models.Inventory{
		ID:     user.InventoryID, // Use the InventoryID from user model
		UserID: userObjID,        // Reference to user
		Items:  []bson.ObjectID{},
		Gear:   []bson.ObjectID{},
		Size:   0,
	}

	// Validate the inventory struct
	if err := validate.Struct(newInventory); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Insert into database
	_, err = inventoryCollection.InsertOne(c, newInventory)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create inventory"})
		return
	}

	c.JSON(http.StatusCreated, newInventory)
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
