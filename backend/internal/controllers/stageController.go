package controllers

import (
	"context"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"

	"github.com/HarDizzeR/Project/backend/internal/database"
	"github.com/HarDizzeR/Project/backend/internal/helpers"
	"github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/HarDizzeR/Project/backend/internal/models"
)

func CreateStage(c *gin.Context) {
	// Verify admin privileges
	err := helpers.CheckUserType(c, "Admin")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get enemy_id from URL parameters
	enemyIDParam := c.Param("enemy_id")
	enemyID, err := bson.ObjectIDFromHex(enemyIDParam)
	if err != nil {
		logger.Errorf("Invalid enemy_id format: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid enemy ID format"})
		return
	}

	// Bind JSON input
	var stage models.Stage
	if err := c.ShouldBindJSON(&stage); err != nil {
		logger.Errorf("Invalid request body: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	// Force EnemyID from URL parameter and generate new Stage ID
	stage.EnemyID = enemyID
	stage.ID = bson.NewObjectID()

	// Validate the stage struct
	if err := validate.Struct(stage); err != nil {
		logger.Errorf("Validation error: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Insert into database
	ctx := context.TODO()
	stagesCollection := database.Stages()
	_, err = stagesCollection.InsertOne(ctx, stage)
	if err != nil {
		logger.Errorf("Database error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": fmt.Sprintf("Database operation failed: %v", err),
		})
		return
	}

	c.JSON(http.StatusCreated, stage)
}

func GetAllStages(c *gin.Context) {
	ctx := context.TODO()
	stagesCollection := database.Stages()

	cursor, err := stagesCollection.Find(ctx, bson.M{})
	if err != nil {
		logger.Errorf("Failed to fetch stages: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve stages"})
		return
	}
	defer cursor.Close(ctx)

	var stages []models.Stage
	if err = cursor.All(ctx, &stages); err != nil {
		logger.Errorf("Failed to decode stages: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process stages"})
		return
	}

	if len(stages) == 0 {
		c.JSON(http.StatusOK, gin.H{"data": []interface{}{}})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": stages})
}

func GetStageByID(c *gin.Context) {
	stageIDParam := c.Param("stageId")
	stageObjID, err := bson.ObjectIDFromHex(stageIDParam)
	if err != nil {
		logger.Errorf("Invalid stage ID format: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid stage ID"})
		return
	}

	ctx := context.TODO()
	stagesCollection := database.Stages()

	var stage models.Stage
	err = stagesCollection.FindOne(ctx, bson.M{"_id": stageObjID}).Decode(&stage)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "Stage not found"})
			return
		}
		logger.Errorf("Database error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve stage"})
		return
	}

	c.JSON(http.StatusOK, stage)
}

func UpdateStage(c *gin.Context) {
	stageIDParam := c.Param("stageId")
	stageObjID, err := bson.ObjectIDFromHex(stageIDParam)
	if err != nil {
		logger.Errorf("Invalid stage ID format: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid stage ID"})
		return
	}

	// Parse the request body as a map
	var requestData map[string]interface{}
	if err := c.ShouldBindJSON(&requestData); err != nil {
		logger.Errorf("Invalid request body: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	// Convert enemy_id to ObjectID if present
	if enemyID, exists := requestData["enemy_id"]; exists {
		enemyIDStr, ok := enemyID.(string)
		if !ok {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid enemy_id format"})
			return
		}

		enemyObjID, err := bson.ObjectIDFromHex(enemyIDStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid enemy_id"})
			return
		}
		requestData["enemy_id"] = enemyObjID
	}

	// Remove empty updates (if a field is explicitly set to null, ignore it)
	update := bson.M{}
	for key, value := range requestData {
		if value != nil {
			update[key] = value
		}
	}

	if len(update) == 0 {
		logger.Error("No valid fields provided for update")
		c.JSON(http.StatusBadRequest, gin.H{"error": "No valid update data provided"})
		return
	}

	// Perform update
	ctx := context.TODO()
	stagesCollection := database.Stages()
	filter := bson.M{"_id": stageObjID}
	updateQuery := bson.M{"$set": update}

	result, err := stagesCollection.UpdateOne(ctx, filter, updateQuery)
	if err != nil {
		logger.Errorf("Update failed: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update stage"})
		return
	}

	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Stage not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"updated_fields": update})
}

func DeleteStage(c *gin.Context) {
	stageIDParam := c.Param("stageId")
	stageObjID, err := bson.ObjectIDFromHex(stageIDParam)
	if err != nil {
		logger.Errorf("Invalid stage ID format: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid stage ID"})
		return
	}

	ctx := context.TODO()
	stagesCollection := database.Stages()

	result, err := stagesCollection.DeleteOne(ctx, bson.M{"_id": stageObjID})
	if err != nil {
		logger.Errorf("Failed to delete stage: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete stage"})
		return
	}

	if result.DeletedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Stage not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Stage deleted successfully"})
}
