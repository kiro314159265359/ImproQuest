package routes

import (
	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/middleware"
	"github.com/gin-gonic/gin"
)

func UserRoutes(incomingRoutes *gin.Engine) {

	users := incomingRoutes.Group("/users")

	users.Use(middleware.Authenticate())

	users.GET("/", middleware.CheckUserType("Admin"), controllers.GetUsers())
	users.GET("/:id", controllers.GetUser())
	users.DELETE("/:id", controllers.DeleteUser())
	users.PATCH("/:id", controllers.UpdateUser())
	users.PATCH("/:id/stats", controllers.UpdateUserStats)

	users.PUT("/quests", controllers.AssignRandomQuests())

	users.POST("/add/:achievement_id", controllers.AddAchievement)
	users.DELETE("/remove/:achievement_id", controllers.RemoveAchievement)

	users.DELETE("/:id/inventory", controllers.DeleteInventoryByUserID)

}
