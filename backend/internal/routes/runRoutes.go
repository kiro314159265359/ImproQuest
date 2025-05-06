package routes

import (
	"github.com/gin-gonic/gin"

	"github.com/HarDizzeR/Project/backend/internal/controllers" // Replace with your actual import path
	"github.com/HarDizzeR/Project/backend/internal/services"    // Replace with your actual import path
)

func SetupRunRoutes(router *gin.Engine, runController *controllers.RunController, wsManager *services.WebSocketManager) {
	// WebSocket endpoint for real-time run data
	router.GET("/ws/runs", func(c *gin.Context) {
		wsManager.HandleConnection(c)
	})

	// API routes
	api := router.Group("/api")
	{
		runs := api.Group("/runs")
		{
			runs.POST("/", runController.SaveRun)

			runs.GET("/users/:userId/histogram/daily", runController.GetDailyHistogram)
			runs.GET("/users/:userId/histogram/weekly", runController.GetWeeklyHistogram)
			runs.GET("/users/:userId/histogram/monthly", runController.GetMonthlyHistogram)

			runs.GET("/users/:userId/stats", runController.GetRunStatistics)
		}
	}
}
