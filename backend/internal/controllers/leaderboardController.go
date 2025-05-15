package controllers

import (
	"context"
	"net/http"
	"strings"
	"time"

	"github.com/HarDizzeR/Project/backend/internal/database"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
)

// GetUserRankLeaderboard returns leaderboard for users with the same rank as the authenticated user
func GetUserRankLeaderboard() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get user ID from context (set by authentication middleware)
		userID := c.GetString("id")

		if userID == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "User ID not found in context"})
			return
		}

		userObjID, err := bson.ObjectIDFromHex(userID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
			return
		}

		// Get leaderboard type from parameter
		leaderboardType := strings.ToLower(c.Param("type"))
		if leaderboardType != "level" && leaderboardType != "streak" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid leaderboard type. Must be 'level' or 'streak'"})
			return
		}

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		// Find user to get their rank
		userCollection := database.Users()
		var user struct {
			Rank string `bson:"rank"`
		}

		err = userCollection.FindOne(ctx, bson.M{"_id": userObjID}).Decode(&user)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user data"})
			return
		}

		// Get leaderboard based on user's rank and specified type
		var leaderboard []bson.M
		if leaderboardType == "level" {
			leaderboard, err = getLevelLeaderboard(ctx, user.Rank)
		} else {
			leaderboard, err = getStreakLeaderboard(ctx, user.Rank)
		}

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch leaderboard data"})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"rank":        user.Rank,
			"type":        leaderboardType,
			"leaderboard": leaderboard,
		})
	}
}

// getLevelLeaderboard fetches level-based leaderboard for a specific rank
func getLevelLeaderboard(ctx context.Context, rank string) ([]bson.M, error) {
	userCollection := database.Users()

	pipeline := mongo.Pipeline{
		// Match users with same rank
		{{Key: "$match", Value: bson.M{"rank": rank}}},
		// Project needed fields (including avatar_url)
		{{Key: "$project", Value: bson.M{
			"_id":        1,
			"username":   1,
			"level":      1,
			"xp":         1,
			"rank":       1,
			"avatar_url": 1,
		}}},
		// Sort by level and XP
		{{Key: "$sort", Value: bson.M{"level": -1, "xp": -1}}},
		// Limit results
		{{Key: "$limit", Value: 100}},
	}

	cursor, err := userCollection.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var results []bson.M
	if err = cursor.All(ctx, &results); err != nil {
		return nil, err
	}
	return results, nil
}

// getStreakLeaderboard fetches streak-based leaderboard for a specific rank
func getStreakLeaderboard(ctx context.Context, rank string) ([]bson.M, error) {
	userCollection := database.Users()

	pipeline := mongo.Pipeline{
		// Match users with same rank
		{{Key: "$match", Value: bson.M{"rank": rank}}},
		// Project needed fields (including avatar_url)
		{{Key: "$project", Value: bson.M{
			"_id":            1,
			"username":       1,
			"current_streak": "$streak.current",
			"highest_streak": "$streak.highest_count",
			"rank":           1,
			"avatar_url":     1,
		}}},
		// Sort by current streak and highest streak
		{{Key: "$sort", Value: bson.M{"current_streak": -1, "highest_streak": -1}}},
		// Limit results
		{{Key: "$limit", Value: 100}},
	}

	cursor, err := userCollection.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var results []bson.M
	if err = cursor.All(ctx, &results); err != nil {
		return nil, err
	}
	return results, nil
}
