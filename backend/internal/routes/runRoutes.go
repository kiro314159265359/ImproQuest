// routes/run_routes.go
package routes

import (
	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/middleware"
	"github.com/gin-gonic/gin"
)

func RunRoutes(router *gin.Engine) {
	// Create a group for /runs routes
	runRoutes := router.Group("/runs")
	runRoutes.Use(middleware.Authenticate())

	// POST /runs - Create a new run entry
	// Maps to the CreateRun function in the controllers package
	runRoutes.POST("/", controllers.CreateRun)

	// GET /runs/histogram?userId=...&period=... - Get aggregated histogram data
	// Maps to the GetRunHistogram function in the controllers package
	runRoutes.GET("/histogram", controllers.GetRunHistogram)

	// runRoutes.GET("/:id", controllers.GetRunById) // You would need to implement GetRunById in controllers

	// runRoutes.GET("/", controllers.GetUserRuns) // You would need to implement GetUserRuns in controllers

}
