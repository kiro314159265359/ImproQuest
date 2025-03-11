package controllers

import (
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"

	"github.com/HarDizzeR/Project/backend/internal/database"
	"github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/HarDizzeR/Project/backend/internal/models"
)

func AddItemToInventory(c *gin.Context) {
	// Get user ID from context and convert it
	userIDStr := c.GetString("id")
	userID, err := bson.ObjectIDFromHex(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID format"})
		return
	}

	// Get item ID from request params and convert it
	itemIDStr := c.Param("itemId")
	itemID, err := bson.ObjectIDFromHex(itemIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid item ID format"})
		return
	}

	// Retrieve the item to get its price
	var item struct {
		ID    bson.ObjectID `bson:"_id"`
		Price float64       `bson:"price"`
		// Include other fields as needed
	}
	err = database.Items().FindOne(context.Background(), bson.M{"_id": itemID}).Decode(&item)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "item not found"})
		return
	}

	// Retrieve the user to check current gold amount
	var user models.User
	err = database.Users().FindOne(context.Background(), bson.M{"_id": userID}).Decode(&user)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}

	// Check if the user has enough gold to buy the item
	if user.Gold < item.Price {
		c.JSON(http.StatusBadRequest, gin.H{"error": "insufficient funds"})
		return
	}

	// Update user's gold by subtracting the item price
	userUpdate := bson.M{
		"$inc": bson.M{"gold": -item.Price},
	}
	userUpdateResult, err := database.Users().UpdateOne(context.Background(), bson.M{"_id": userID}, userUpdate)
	if err != nil || userUpdateResult.ModifiedCount == 0 {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update user funds"})
		return
	}

	// Add the item to the user's inventory and update its size
	invCollection := database.Inventories()
	invFilter := bson.M{"user_id": userID}
	invUpdate := bson.M{
		"$push": bson.M{"items": itemID},
		"$inc":  bson.M{"size": 1},
	}
	invResult, err := invCollection.UpdateOne(context.Background(), invFilter, invUpdate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update inventory"})
		return
	}
	if invResult.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "inventory not found for user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":        "success",
		"modifiedCount": invResult.ModifiedCount,
	})
}

func RemoveItemFromInventory(c *gin.Context) {
	// Get user ID from context
	userIDStr := c.GetString("id")
	userID, err := bson.ObjectIDFromHex(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user ID format"})
		return
	}

	// Get item ID from request params
	itemIDStr := c.Param("itemId")
	itemID, err := bson.ObjectIDFromHex(itemIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid item ID format"})
		return
	}

	// Check if the item exists in the items collection
	itemsCollection := database.Items()
	itemFilter := bson.M{"_id": itemID}
	itemResult := itemsCollection.FindOne(context.Background(), itemFilter)
	if itemResult.Err() != nil {
		if itemResult.Err() == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "item does not exist"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "database error"})
		return
	}

	// Find and update inventory
	inventoryCollection := database.Inventories()
	inventoryFilter := bson.M{"user_id": userID, "items": itemID} // Ensure the item exists in the user's inventory

	update := bson.M{
		"$pull": bson.M{"items": itemID}, // Remove the item from the array
		"$inc":  bson.M{"size": -1},      // Decrement the size (optional)
	}

	result, err := inventoryCollection.UpdateOne(
		context.Background(),
		inventoryFilter,
		update,
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "database operation failed"})
		return
	}

	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "item not found in user's inventory"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":        "success",
		"modifiedCount": result.ModifiedCount,
	})
}

func CreateItem(c *gin.Context) {

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
	_, err := itemsCollection.InsertOne(ctx, item)
	if err != nil {
		logger.Errorf("Failed to create item: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create item"})
		return
	}

	c.JSON(http.StatusCreated, item)
}

func UpdateItem(c *gin.Context) {

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

func GetAllItems(c *gin.Context) {

	ctx := context.TODO()
	itemsCollection := database.Items()

	// Find all items
	cursor, err := itemsCollection.Find(ctx, bson.M{})
	if err != nil {
		logger.Errorf("Failed to fetch items: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve items"})
		return
	}
	defer cursor.Close(ctx)

	var items []models.Item
	if err = cursor.All(ctx, &items); err != nil {
		logger.Errorf("Failed to decode items: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process items"})
		return
	}

	if len(items) == 0 {
		c.JSON(http.StatusOK, gin.H{"message": "No items found", "data": []interface{}{}})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": items})
}

func GetItemById(c *gin.Context) {

	itemIDParam := c.Param("itemId")
	itemObjID, err := bson.ObjectIDFromHex(itemIDParam)
	if err != nil {
		logger.Errorf("Invalid item ID format: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item ID"})
		return
	}

	ctx := context.TODO()
	itemsCollection := database.Items()

	var item models.Item
	err = itemsCollection.FindOne(ctx, bson.M{"_id": itemObjID}).Decode(&item)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "Item not found"})
			return
		}
		logger.Errorf("Database error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve item"})
		return
	}

	c.JSON(http.StatusOK, item)
}

func DeleteItem(c *gin.Context) {

	// Parse item ID from the request
	itemIDParam := c.Param("itemId")
	itemObjID, err := bson.ObjectIDFromHex(itemIDParam)
	if err != nil {
		logger.Errorf("Invalid item ID format: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item ID"})
		return
	}

	ctx := c.Request.Context()
	itemsCollection := database.Items()

	// Delete the item
	result, err := itemsCollection.DeleteOne(ctx, bson.M{"_id": itemObjID})
	if err != nil {
		logger.Errorf("Failed to delete item: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete item"})
		return
	}

	if result.DeletedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Item not found"})
		return
	}

	// Remove the item from all related collections (e.g., user inventories or orders)
	inventoryCollection := database.Inventories()
	_, err = inventoryCollection.UpdateMany(
		ctx,
		bson.M{"items": itemObjID}, // Find documents containing this item
		bson.M{"$pull": bson.M{"items": itemObjID}}, // Remove the item from the array
	)
	if err != nil {
		logger.Errorf("Item deleted but failed to remove from inventories: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Item deleted but failed to remove from inventories",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Item deleted and removed from all inventories",
	})
}
