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

func CreateStage(c *gin.Context) {
	var stage models.Stage
	if err := c.ShouldBindJSON(&stage); err != nil {
		logger.Errorf("Invalid request body: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	if !helpers.IsValidEnemy(stage.EnemyID) {
		logger.Errorf("Invalid enemy ID: %v", stage.EnemyID)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid enemy reference"})
		return
	}

	// Generate new ID and validate
	stage.ID = bson.NewObjectID()
	if err := validate.Struct(stage); err != nil {
		logger.Errorf("Validation failed: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Insert into database
	ctx := context.TODO()
	stagesCollection := database.Stages()
	_, err := stagesCollection.InsertOne(ctx, stage)
	if err != nil {
		logger.Errorf("Failed to create stage: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create stage"})
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

	var updateData models.Stage
	if err := c.ShouldBindJSON(&updateData); err != nil {
		logger.Errorf("Invalid request body: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	// Ensure ID matches URL parameter
	updateData.ID = stageObjID

	// Validate updated data
	if err := validate.Struct(updateData); err != nil {
		logger.Errorf("Validation failed: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if !helpers.IsValidEnemy(updateData.EnemyID) {
		logger.Errorf("Invalid enemy ID: %v", updateData.EnemyID)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid enemy reference"})
		return
	}

	// Perform update
	ctx := context.TODO()
	stagesCollection := database.Stages()
	filter := bson.M{"_id": stageObjID}
	update := bson.M{"$set": updateData}

	result, err := stagesCollection.UpdateOne(ctx, filter, update)
	if err != nil {
		logger.Errorf("Update failed: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update stage"})
		return
	}

	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Stage not found"})
		return
	}

	c.JSON(http.StatusOK, updateData)
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
