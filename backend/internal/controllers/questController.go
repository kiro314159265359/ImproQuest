package controllers

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"

	"github.com/HarDizzeR/Project/backend/internal/database"
	"github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/HarDizzeR/Project/backend/internal/models"
)

var questCollection *mongo.Collection = database.Quests()

type QuestRequest struct {
	Name       *string  `json:"Name" validate:"required,min=3,max=100"`
	XPReward   *float64 `json:"XPReward" validate:"required,gte=0"`
	GoldReward *float64 `json:"GoldReward" validate:"required,gte=0"`
	Difficulty *string  `json:"Difficulty" validate:"required,oneof=Easy Medium Hard"`
}

// Create Quest

func CreateQuest() gin.HandlerFunc {
	return func(c *gin.Context) {

		var questReq QuestRequest

		if err := c.ShouldBindJSON(&questReq); err != nil {
			logger.Errorf("Invalid Request Format: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		if err := validate.Struct(questReq); err != nil {
			var validationErrors []string
			for _, err := range err.(validator.ValidationErrors) {
				validationErrors = append(validationErrors, fmt.Sprintf("%s: %s", err.Field(), err.Tag()))
			}
			logger.Errorf("Validation error: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"errors": validationErrors})
			return
		}

		quest := models.Quest{
			Name:       questReq.Name,
			XPReward:   questReq.XPReward,
			GoldReward: questReq.GoldReward,
			Difficulty: questReq.Difficulty,
		}

		quest.ID = bson.NewObjectID()
		quest.IsCompleted = false

		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		_, err := questCollection.InsertOne(ctx, quest)
		if err != nil {
			logger.Errorf("Error while creating Quest: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		c.JSON(http.StatusCreated, quest)
	}
}

// Get all Quests with pagination

func GetQuests() gin.HandlerFunc {
	return func(c *gin.Context) {
		var quests []models.Quest
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		cursor, err := questCollection.Find(ctx, bson.M{})
		if err != nil {
			logger.Errorf("Error while fetching Quests: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		if err = cursor.All(ctx, &quests); err != nil {
			logger.Errorf("Error while decoding Quests: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		c.JSON(http.StatusOK, gin.H{"length": len(quests), "quests": quests})
	}
}

// Get Quest by ID

func GetQuest() gin.HandlerFunc {
	return func(c *gin.Context) {
		questID := c.Param("id")
		objectID, err := bson.ObjectIDFromHex(questID)
		if err != nil {
			logger.Errorf("Invalid quest ID format: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid quest ID format"})
			return
		}

		var quest models.Quest
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		err = questCollection.FindOne(ctx, bson.M{"_id": objectID}).Decode(&quest)
		if err != nil {
			logger.Errorf("Error while fetching Quest: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		c.JSON(http.StatusOK, quest)
	}
}

// Update Quest

func UpdateQuest() gin.HandlerFunc {
	return func(c *gin.Context) {

		questID := c.Param("id")
		objectID, err := bson.ObjectIDFromHex(questID)
		if err != nil {
			logger.Errorf("Invalid quest ID format: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid quest ID format"})
			return
		}

		var updateData bson.M
		if err := c.ShouldBindJSON(&updateData); err != nil {
			logger.Errorf("Invalid Request Format: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		update := bson.M{"$set": updateData}
		result, err := questCollection.UpdateOne(ctx, bson.M{"_id": objectID}, update)
		if err != nil {
			logger.Errorf("Error while updating Quest: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		if result.MatchedCount == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "Quest not found"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Quest updated successfully", "modified_count": result.ModifiedCount})
	}
}

// Delete Quest

func DeleteQuest() gin.HandlerFunc {
	return func(c *gin.Context) {

		questID := c.Param("id")
		objectID, err := bson.ObjectIDFromHex(questID)
		if err != nil {
			logger.Errorf("Invalid quest ID format: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid quest ID format"})
			return
		}

		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		result, err := questCollection.DeleteOne(ctx, bson.M{"_id": objectID})
		if err != nil {
			logger.Errorf("Error while deleting Quest: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		if result.DeletedCount == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "Quest not found"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Quest deleted successfully"})
	}
}
