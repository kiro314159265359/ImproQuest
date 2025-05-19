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
	achievements.POST("/create", middleware.CheckUserType("Admin"), controllers.CreateAchievement)
	achievements.POST("/add/:achievement_id", middleware.CheckUserType("Admin"), controllers.AddAchievement) // Assuming Admin adds to current user or needs user_id param
	achievements.GET("/", controllers.GetAllAchievements)
	achievements.GET("/:id", controllers.GetAchievementByID)                                      // :id is achievement_id
	achievements.PUT("/:id", middleware.CheckUserType("Admin"), controllers.UpdateAchievement)    // :id is achievement_id
	achievements.DELETE("/:id", middleware.CheckUserType("Admin"), controllers.DeleteAchievement) // :id is achievement_id
	achievements.DELETE("/remove/:achievement_id", middleware.CheckUserType("Admin"), controllers.RemoveAchievement)

	// user-specific lists
	achievements.GET("/unlocked", controllers.GetUserUnlockedAchievements())
	achievements.GET("/locked", controllers.GetUserLockedAchievements())
}
