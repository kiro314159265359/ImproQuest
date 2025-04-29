package routes

import (
	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/middleware"
	"github.com/gin-gonic/gin"
)

func UserRoutes(incomingRoutes *gin.Engine) {

	users := incomingRoutes.Group("/users")

	users.Use(middleware.Authenticate())

	users.GET("/mydata", controllers.GetMyData())
	users.GET("/", controllers.GetUsers())
	users.GET("/:id", controllers.GetUser())
	users.DELETE("/:id", controllers.DeleteUser())
	users.PATCH("/:id", controllers.UpdateUser())
	users.PATCH("/:id/stats", controllers.UpdateUserStats())

	users.POST("/customQuest", controllers.CreateCustomQuest())

	users.PUT("/quests", controllers.AssignRandomQuests())
	users.PUT("/updateQuestProgress", controllers.UpdateRunningQuestProgress())

	users.POST("/add/:achievement_id", controllers.AddAchievement)
	users.DELETE("/remove/:achievement_id", controllers.RemoveAchievement)

	users.DELETE("/:id/inventory", controllers.DeleteInventoryByUserID)

	users.POST("/equip", controllers.EquipItem())
	users.POST("/unequip", controllers.UnequipItem())
	users.GET("/inventory/items", controllers.GetUserInventoryItems()) // New route

}
