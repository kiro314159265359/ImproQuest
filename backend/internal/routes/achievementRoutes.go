package routes

import (
	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/middleware"
	"github.com/gin-gonic/gin"
)

func AchievementRoutes(router *gin.Engine) {
	achievements := router.Group("/achievements")
	achievements.Use(middleware.Authenticate())
	// admin routes
	achievements.POST("/create", controllers.CreateAchievement)
	achievements.GET("/", controllers.GetAllAchievements)
	achievements.GET("/:id", controllers.GetAchievementByID)
	achievements.PUT("/:id", controllers.UpdateAchievement)
	achievements.DELETE("/:id", controllers.DeleteAchievement)
	// user routes
	achievements.POST("/add/:achievement_id", controllers.AddAchievement)
	achievements.DELETE("/remove/:achievement_id", controllers.RemoveAchievement)

}
