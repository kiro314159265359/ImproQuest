package routes

import (
    "github.com/HarDizzeR/Project/backend/internal/controllers"
    "github.com/HarDizzeR/Project/backend/internal/middleware"
    "github.com/gin-gonic/gin"
)

// LeaderboardRoutes sets up the leaderboard API routes
func LeaderboardRoutes(router *gin.Engine) {
    leaderboard := router.Group("/leaderboard")
    leaderboard.Use(middleware.Authenticate())

    // Get leaderboard of users with same rank as authenticated user
    // Parameter can be "level" or "streak"
    leaderboard.GET("/:type", controllers.GetUserRankLeaderboard())
}