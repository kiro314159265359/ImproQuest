package routes

import (
	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/middleware"

	"github.com/gin-gonic/gin"
)

func StageRoutes(router *gin.Engine) {
	adminRoutes := router.Group("/stages")
	adminRoutes.Use(middleware.Authenticate())
	adminRoutes.POST("/create/:enemy_id", middleware.CheckUserType("Admin"), controllers.CreateStage)

	adminRoutes.GET("/", controllers.GetAllStages)
	adminRoutes.GET("/:stageId", controllers.GetStageByID)

	adminRoutes.PUT("/:stageId", middleware.CheckUserType("Admin"), controllers.UpdateStage)

	adminRoutes.DELETE("/:stageId", middleware.CheckUserType("Admin"), controllers.DeleteStage)
}
