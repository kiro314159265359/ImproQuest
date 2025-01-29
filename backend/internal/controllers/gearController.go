package controllers

import (
	"log"
	"net/http"

	"github.com/HarDizzeR/Project/backend/internal/models"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"

	"github.com/HarDizzeR/Project/backend/internal/database"
)

func CreateGear(c *gin.Context) {
	var gear models.Gear

	// Bind JSON request
	if err := c.ShouldBindJSON(&gear); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":  "Invalid request body",
			"detail": err.Error(),
		})
		return
	}

	// Generate MongoDB ID BEFORE validation
	gear.ID = bson.NewObjectID()

	// Validate Struct (now includes generated ID)
	if err := validate.Struct(gear); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":  "Validation failed",
			"detail": err.Error(),
		})
		return
	}

	// Get database collection
	gearCollection := database.Gears()
	if gearCollection == nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Database connection failed",
		})
		return
	}

	// Insert into MongoDB
	result, err := gearCollection.InsertOne(c.Request.Context(), gear)
	if err != nil {
		log.Printf("Database insert error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":  "Failed to create gear",
			"detail": err.Error(),
		})
		return
	}

	// Success Response
	c.JSON(http.StatusCreated, gin.H{
		"message": "Gear created successfully",
		"gear_id": result.InsertedID,
		"gear":    gear,
	})
}

func GetAllGears(c *gin.Context) {
	gearCollection := database.Gears()
	var gears []models.Gear

	cursor, err := gearCollection.Find(c.Request.Context(), bson.M{})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch gears"})
		return
	}
	defer cursor.Close(c.Request.Context())

	for cursor.Next(c.Request.Context()) {
		var gear models.Gear
		if err := cursor.Decode(&gear); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error decoding gear"})
			return
		}
		gears = append(gears, gear)
	}

	if err := cursor.Err(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Cursor error"})
		return
	}

	c.JSON(http.StatusOK, gears)
}

func GetGearByID(c *gin.Context) {
	id := c.Param("id")

	objID, err := bson.ObjectIDFromHex(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
		return
	}

	var gear models.Gear
	gearCollection := database.Gears()
	err = gearCollection.FindOne(c.Request.Context(), bson.M{"_id": objID}).Decode(&gear)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "Gear not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch gear"})
		return
	}

	c.JSON(http.StatusOK, gear)
}

func DeleteGear(c *gin.Context) {
	id := c.Param("id")

	objID, err := bson.ObjectIDFromHex(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
		return
	}
	gearCollection := database.Gears()
	result, err := gearCollection.DeleteOne(c.Request.Context(), bson.M{"_id": objID})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete gear"})
		return
	}

	if result.DeletedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Gear not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Gear deleted successfully"})
}

func AddGear(c *gin.Context) {
	// Get authenticated user ID from context
	userID := c.GetString("id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User authentication required"})
		return
	}

	// Convert user ID to ObjectID
	userObjID, err := bson.ObjectIDFromHex(userID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID format"})
		return
	}

	// Get gear ID from request params
	gearID := c.Param("id")
	gearObjID, err := bson.ObjectIDFromHex(gearID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid gear ID format"})
		return
	}

	// Check if gear exists
	gearCollection := database.Gears()
	var gear models.Gear
	err = gearCollection.FindOne(c.Request.Context(), bson.M{"_id": gearObjID}).Decode(&gear)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "Gear not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Update inventory
	inventoryCollection := database.Inventories()
	filter := bson.M{"user_id": userObjID}
	update := bson.M{"$addToSet": bson.M{"gear": gearObjID}}

	result, err := inventoryCollection.UpdateOne(c.Request.Context(), filter, update)
	if err != nil {
		log.Printf("Inventory update error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update inventory"})
		return
	}

	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "User inventory not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Gear added to inventory",
		"gear_id": gearObjID,
		"matched": result.MatchedCount,
		"updated": result.ModifiedCount,
	})
}

func RemoveGear(c *gin.Context) {
	// Get authenticated user ID from context
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User authentication required"})
		return
	}

	// Convert user ID to ObjectID
	userObjID, err := bson.ObjectIDFromHex(userID.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID format"})
		return
	}

	// Get gear ID from request params
	gearID := c.Param("id")
	gearObjID, err := bson.ObjectIDFromHex(gearID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid gear ID format"})
		return
	}

	// Check if gear exists
	gearCollection := database.Gears()
	var gear models.Gear
	err = gearCollection.FindOne(c.Request.Context(), bson.M{"_id": gearObjID}).Decode(&gear)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "Gear not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Update inventory to remove gear
	inventoryCollection := database.Inventories()
	filter := bson.M{"user_id": userObjID}
	update := bson.M{"$pull": bson.M{"gear": gearObjID}}

	result, err := inventoryCollection.UpdateOne(c.Request.Context(), filter, update)
	if err != nil {
		log.Printf("Inventory update error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update inventory"})
		return
	}

	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "User inventory not found"})
		return
	}

	response := gin.H{
		"message": "Gear removed from inventory",
		"gear_id": gearObjID,
		"matched": result.MatchedCount,
		"updated": result.ModifiedCount,
	}

	if result.ModifiedCount == 0 {
		response["warning"] = "Gear was not found in inventory"
	}

	c.JSON(http.StatusOK, response)
}
