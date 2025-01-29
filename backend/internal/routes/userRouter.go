package routes

import (
	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/middleware"
	"github.com/gin-gonic/gin"
)

func UserRoutes(incomingRoutes *gin.Engine) {

	users := incomingRoutes.Group("/users")

	users.GET("/logout", controllers.Logout())

	users.Use(middleware.Authenticate())

	users.GET("/", controllers.GetUsers())
	users.GET("/:id", controllers.GetUser())
	users.DELETE("/:id", controllers.DeleteUser())
	users.PATCH("/:id", controllers.UpdateUser())
	users.PUT("/quests", controllers.AssignRandomQuests())

	// user routes
	users.POST("/add/:achievement_id", controllers.AddAchievement)
	users.DELETE("/remove/:achievement_id", controllers.RemoveAchievement)
}
