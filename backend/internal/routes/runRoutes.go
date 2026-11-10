package routes

import (
	"github.com/gin-gonic/gin"

	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/middleware"
	"github.com/HarDizzeR/Project/backend/internal/services"
)

func SetupRunRoutes(router *gin.Engine, runController *controllers.RunController, wsManager *services.WebSocketManager) {
	// WebSocket endpoint for real-time run data
	router.GET("/ws/runs", func(c *gin.Context) {
		wsManager.HandleConnection(c)
	})

	{
		runs := router.Group("/runs")
		runs.Use(middleware.Authenticate())

		runs.GET("/:userId/distance/today", runController.GetTodayTotalDistance)
		runs.GET("/:userId/distance/days-of-week", runController.GetDailyDistancesForWeek)     // Query: ?date=YYYY-MM-DD
		runs.GET("/:userId/distance/weeks-of-month", runController.GetWeeklyDistancesForMonth) // Query: ?date=YYYY-MM-DD
		runs.GET("/:userId/distance/months-of-year", runController.GetMonthlyDistancesForYear) // Query: ?year=YYYY

	}
}
