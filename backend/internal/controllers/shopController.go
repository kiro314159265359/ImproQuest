package controllers

import (
	"context"
	"net/http"

	"github.com/HarDizzeR/Project/backend/internal/database"
	"github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/HarDizzeR/Project/backend/internal/models"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
)

// GetPermanentItems returns all permanent shop items
func GetPermanentItems(c *gin.Context) {
	ctx := context.TODO()
	itemsCollection := database.Items()

	// Find all permanent items
	cursor, err := itemsCollection.Find(ctx, bson.M{"is_permanent": true})
	if err != nil {
		logger.Errorf("Failed to fetch permanent items: %v", err)
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
		c.JSON(http.StatusOK, gin.H{"message": "No permanent items found", "data": []interface{}{}})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": items})
}

// CreatePermanentItem creates a new permanent shop item
func CreatePermanentItem(c *gin.Context) {
	// Parse request body
	var item models.Item
	if err := c.ShouldBindJSON(&item); err != nil {
		logger.Errorf("Invalid request body: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	// Generate new ID, set permanent flag, and validate
	item.ID = bson.NewObjectID()
	item.IsPermanent = true

	// Additional validation for equipment items
	if item.Type == "equipment" && item.Slot == "" {
		logger.Errorf("Equipment items must specify a slot")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Equipment items must specify a valid slot"})
		return
	}

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
		logger.Errorf("Failed to create permanent item: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create item"})
		return
	}

	c.JSON(http.StatusCreated, item)
}

// UpdatePermanentItem updates an existing permanent shop item
func UpdatePermanentItem(c *gin.Context) {
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

	// Force use URL ID, set permanent flag, and validate
	updateData.ID = itemObjID
	updateData.IsPermanent = true

	// Additional validation for equipment items
	if updateData.Type == "equipment" && updateData.Slot == "" {
		logger.Errorf("Equipment items must specify a slot")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Equipment items must specify a valid slot"})
		return
	}

	if err := validate.Struct(updateData); err != nil {
		logger.Errorf("Validation failed: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Update in database
	ctx := context.TODO()
	filter := bson.M{"_id": itemObjID, "is_permanent": true}
	update := bson.M{"$set": updateData}

	itemsCollection := database.Items()
	result, err := itemsCollection.UpdateOne(ctx, filter, update)
	if err != nil {
		logger.Errorf("Failed to update item: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update item"})
		return
	}

	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Permanent item not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Permanent item updated successfully",
		"updated": result.ModifiedCount,
	})
}

// DeletePermanentItem deletes a permanent shop item
func DeletePermanentItem(c *gin.Context) {
	// Get item ID from URL
	itemIDParam := c.Param("itemId")
	itemObjID, err := bson.ObjectIDFromHex(itemIDParam)
	if err != nil {
		logger.Errorf("Invalid item ID: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item ID"})
		return
	}

	// Delete from database
	ctx := context.TODO()
	filter := bson.M{"_id": itemObjID, "is_permanent": true}

	itemsCollection := database.Items()
	result, err := itemsCollection.DeleteOne(ctx, filter)
	if err != nil {
		logger.Errorf("Failed to delete item: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete item"})
		return
	}

	if result.DeletedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Permanent item not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Permanent item deleted successfully",
		"deleted": result.DeletedCount,
	})
}

// GetConsumableItems returns all consumable (temporary) shop items
func GetConsumableItems(c *gin.Context) {
	ctx := context.TODO()
	itemsCollection := database.Items()

	// Find all consumable items (non-permanent and type: consumable)
	cursor, err := itemsCollection.Find(ctx, bson.M{
		"is_permanent": false,
		"type":         "consumable",
	})
	if err != nil {
		logger.Errorf("Failed to fetch consumable items: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve consumable items"})
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
		c.JSON(http.StatusOK, gin.H{"message": "No consumable items found", "data": []interface{}{}})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": items})
}

// CreateConsumableItem creates a new temporary consumable shop item
func CreateConsumableItem(c *gin.Context) {
	// Parse request body
	var item models.Item
	if err := c.ShouldBindJSON(&item); err != nil {
		logger.Errorf("Invalid request body: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	// Generate new ID, set as non-permanent and type as consumable, then validate
	item.ID = bson.NewObjectID()
	item.IsPermanent = false
	item.Type = "consumable"
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
		logger.Errorf("Failed to create consumable item: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create item"})
		return
	}

	c.JSON(http.StatusCreated, item)
}

// UpdateConsumableItem updates an existing temporary consumable shop item
func UpdateConsumableItem(c *gin.Context) {
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

	// Force use URL ID, ensure item remains non-permanent and type is consumable, then validate
	updateData.ID = itemObjID
	updateData.IsPermanent = false
	updateData.Type = "consumable"
	if err := validate.Struct(updateData); err != nil {
		logger.Errorf("Validation failed: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Update in database
	ctx := context.TODO()
	filter := bson.M{"_id": itemObjID, "is_permanent": false, "type": "consumable"}
	update := bson.M{"$set": updateData}

	itemsCollection := database.Items()
	result, err := itemsCollection.UpdateOne(ctx, filter, update)
	if err != nil {
		logger.Errorf("Failed to update item: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update item"})
		return
	}

	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Consumable item not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Consumable item updated successfully",
		"updated": result.ModifiedCount,
	})
}

// DeleteConsumableItem deletes a temporary consumable shop item
func DeleteConsumableItem(c *gin.Context) {
	// Get item ID from URL
	itemIDParam := c.Param("itemId")
	itemObjID, err := bson.ObjectIDFromHex(itemIDParam)
	if err != nil {
		logger.Errorf("Invalid item ID: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid item ID"})
		return
	}

	// Delete from database
	ctx := context.TODO()
	filter := bson.M{"_id": itemObjID, "is_permanent": false, "type": "consumable"}

	itemsCollection := database.Items()
	result, err := itemsCollection.DeleteOne(ctx, filter)
	if err != nil {
		logger.Errorf("Failed to delete item: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete item"})
		return
	}

	if result.DeletedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Consumable item not found"})
		return
	}

	// Remove from all inventories
	inventoryCollection := database.Inventories()
	_, err = inventoryCollection.UpdateMany(
		ctx,
		bson.M{"items": itemObjID},
		bson.M{"$pull": bson.M{"items": itemObjID}},
	)
	if err != nil {
		logger.Errorf("Item deleted but failed to remove from inventories: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"warning": "Item deleted but failed to remove from inventories",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Consumable item deleted successfully",
		"deleted": result.DeletedCount,
	})
}

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

	// Retrieve the item to get its price and check if it's equipment
	var item models.Item
	err = database.Items().FindOne(context.Background(), bson.M{"_id": itemID}).Decode(&item)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "item not found"})
		return
	}

	// Check if it's a permanent equipment item
	isPermanentEquipment := item.IsPermanent && item.Type == "equipment"

	// If it's permanent equipment, check if the user already has it
	if isPermanentEquipment {
		// Get user's inventory
		var inventory models.Inventory
		err = database.Inventories().FindOne(context.Background(), bson.M{"user_id": userID}).Decode(&inventory)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to retrieve user inventory"})
			return
		}

		// Check if the item is already in the inventory
		for _, existingItemID := range inventory.Items {
			if existingItemID == itemID {
				c.JSON(http.StatusBadRequest, gin.H{"error": "you already own this equipment item"})
				return
			}
		}
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
		"item":          item,
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
