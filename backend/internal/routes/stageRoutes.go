package routes

import (
	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/middleware"

	"github.com/gin-gonic/gin"
)

func StageRoutes(router *gin.Engine) {
	adminRoutes := router.Group("/stages")
	adminRoutes.Use(middleware.Authenticate())
	adminRoutes.POST("/create/:enemy_id", controllers.CreateStage)

	adminRoutes.GET("/", controllers.GetAllStages)
	adminRoutes.GET("/:stageId", controllers.GetStageByID)

	adminRoutes.PUT("/:stageId", controllers.UpdateStage)

	adminRoutes.DELETE("/:stageId", controllers.DeleteStage)
}
