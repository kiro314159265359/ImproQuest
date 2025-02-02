package controllers

import (
	"context"
	"fmt"
	"net/http"

	"github.com/HarDizzeR/Project/backend/internal/database"
	"github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/HarDizzeR/Project/backend/internal/models"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
)

func CreateEnemy(c *gin.Context) {

	var enemy models.Enemy
	if err := c.ShouldBindJSON(&enemy); err != nil {
		logger.Errorf("Invalid request body: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	if err := validate.Struct(enemy); err != nil {
		logger.Errorf("Validation error: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	// Generate new ID and validate
	enemy.ID = bson.NewObjectID()
	if err := validate.Struct(enemy); err != nil {
		logger.Errorf("Validation failed: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Insert into database
	ctx := context.TODO()
	enemiesCollection := database.Enemies()
	_, err := enemiesCollection.InsertOne(ctx, enemy)
	if err != nil {
		logger.Errorf("Database error: %v", err) // Now shows actual error
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": fmt.Sprintf("Database operation failed: %v", err),
		})
		return
	}

	c.JSON(http.StatusCreated, enemy)
}

// GetAllEnemies returns all enemies
func GetAllEnemies(c *gin.Context) {
	ctx := context.TODO()
	enemiesCollection := database.Enemies()

	cursor, err := enemiesCollection.Find(ctx, bson.M{})
	if err != nil {
		logger.Errorf("Failed to fetch enemies: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve enemies"})
		return
	}
	defer cursor.Close(ctx)

	var enemies []models.Enemy
	if err = cursor.All(ctx, &enemies); err != nil {
		logger.Errorf("Failed to decode enemies: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process enemies"})
		return
	}

	if len(enemies) == 0 {
		c.JSON(http.StatusOK, gin.H{"data": []interface{}{}})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": enemies})
}

func GetEnemyByID(c *gin.Context) {
	enemyIDParam := c.Param("enemyId")
	enemyObjID, err := bson.ObjectIDFromHex(enemyIDParam)
	if err != nil {
		logger.Errorf("Invalid enemy ID format: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid enemy ID"})
		return
	}

	ctx := context.TODO()
	enemiesCollection := database.Enemies()

	var enemy models.Enemy
	err = enemiesCollection.FindOne(ctx, bson.M{"_id": enemyObjID}).Decode(&enemy)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "Enemy not found"})
			return
		}
		logger.Errorf("Database error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve enemy"})
		return
	}

	c.JSON(http.StatusOK, enemy)
}

// UpdateEnemy updates an existing enemy
func UpdateEnemy(c *gin.Context) {
	enemyIDParam := c.Param("enemyId")
	enemyObjID, err := bson.ObjectIDFromHex(enemyIDParam)
	if err != nil {
		logger.Errorf("Invalid enemy ID format: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid enemy ID"})
		return
	}

	var updateData models.Enemy
	if err := c.ShouldBindJSON(&updateData); err != nil {
		logger.Errorf("Invalid request body: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	// Ensure ID matches URL parameter
	updateData.ID = enemyObjID

	// Validate updated data
	if err := validate.Struct(updateData); err != nil {
		logger.Errorf("Validation failed: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Perform update
	ctx := context.TODO()
	enemiesCollection := database.Enemies()
	filter := bson.M{"_id": enemyObjID}
	update := bson.M{"$set": updateData}

	result, err := enemiesCollection.UpdateOne(ctx, filter, update)
	if err != nil {
		logger.Errorf("Update failed: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update enemy"})
		return
	}

	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Enemy not found"})
		return
	}

	c.JSON(http.StatusOK, updateData)
}

// DeleteEnemy deletes an enemy
func DeleteEnemy(c *gin.Context) {
	enemyIDParam := c.Param("enemyId")
	enemyObjID, err := bson.ObjectIDFromHex(enemyIDParam)
	if err != nil {
		logger.Errorf("Invalid enemy ID format: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid enemy ID"})
		return
	}

	ctx := context.TODO()
	enemiesCollection := database.Enemies()

	result, err := enemiesCollection.DeleteOne(ctx, bson.M{"_id": enemyObjID})
	if err != nil {
		logger.Errorf("Failed to delete enemy: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete enemy"})
		return
	}

	if result.DeletedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Enemy not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Enemy deleted successfully"})
}
