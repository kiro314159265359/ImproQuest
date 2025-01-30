package controllers

import (
	"context"
	"log"
	"net/http"

	"github.com/HarDizzeR/Project/backend/internal/helpers"
	"github.com/HarDizzeR/Project/backend/internal/models"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"

	"github.com/HarDizzeR/Project/backend/internal/database"
)

type GearUpdate struct {
	Name          *string       `json:"name,omitempty" bson:"name,omitempty" validate:"omitempty,min=1,max=100"`
	Type          *string       `json:"type,omitempty" bson:"type,omitempty" validate:"omitempty,oneof=helmet chestplate leggings boots"`
	StatBonuses   *models.Stats `json:"stat_bonuses,omitempty" bson:"stat_bonuses,omitempty"`
	Price         *float64      `json:"price,omitempty" bson:"price,omitempty" validate:"omitempty,gte=0"`
	LevelRequired *int          `json:"level_required,omitempty" bson:"level_required,omitempty" validate:"omitempty,gte=1"`
}

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

func UpdateGear(c *gin.Context) {
	// 1. Authorization check
	if err := helpers.CheckUserType(c, "Admin"); err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "unauthorized access"})
		return
	}

	// 2. Get and validate ID
	gearID := c.Param("id")
	objID, err := bson.ObjectIDFromHex(gearID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid gear ID"})
		return
	}

	// 3. Bind to update-specific struct
	var updateData GearUpdate
	if err := c.ShouldBindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request body"})
		return
	}

	// 4. Validate only provided fields
	if err := validate.StructPartial(updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 5. Build update document
	update := bson.M{"$set": bson.M{}}
	setValues := update["$set"].(bson.M)

	// Handle pointer fields
	if updateData.Name != nil {
		setValues["name"] = *updateData.Name
	}
	if updateData.Type != nil {
		setValues["type"] = *updateData.Type
	}
	if updateData.Price != nil {
		setValues["price"] = *updateData.Price
	}
	if updateData.LevelRequired != nil {
		setValues["level_required"] = *updateData.LevelRequired
	}

	// Handle nested stats
	if updateData.StatBonuses != nil {
		stats := *updateData.StatBonuses
		if stats.Vitality != nil && *stats.Vitality > 0 {
			setValues["stat_bonuses.vitality"] = *stats.Vitality
		}
		if stats.Strength != nil && *stats.Strength > 0 {
			setValues["stat_bonuses.strength"] = *stats.Strength
		}
		// Add similar checks for other stats
	}

	// 6. Check for empty update
	if len(setValues) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "no fields to update"})
		return
	}

	// 7. Database operation
	gearCollection := database.Gears()
	result, err := gearCollection.UpdateOne(
		context.Background(),
		bson.M{"_id": objID},
		update,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "database operation failed"})
		return
	}

	// 8. Check if document was actually found
	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "gear not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  "success",
		"updated": result.ModifiedCount,
	})
}

func DeleteGear(c *gin.Context) {
	id := c.Param("id")

	objID, err := bson.ObjectIDFromHex(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
		return
	}

	// First delete the gear
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

	// Then remove it from all user inventories
	inventoryCollection := database.Inventories()
	_, err = inventoryCollection.UpdateMany(
		c.Request.Context(),
		bson.M{"gear": objID},                  // Find inventories containing this gear
		bson.M{"$pull": bson.M{"gear": objID}}, // Remove the gear from the array
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Gear deleted but failed to remove from inventories",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Gear deleted and removed from all inventories",
	})
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
	userID, exists := c.Get("id")
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
