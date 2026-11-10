package routes

import (
	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/middleware"
	"github.com/gin-gonic/gin"
)

func QuestRoutes(incomingRoutes *gin.Engine) {

	quests := incomingRoutes.Group("/quests")

	quests.Use(middleware.Authenticate())

	quests.GET("/", controllers.GetQuests())
	quests.POST("/", middleware.CheckUserType("Admin"), controllers.CreateQuest())
	quests.GET("/:id", controllers.GetQuest())
	quests.DELETE("/:id", middleware.CheckUserType("Admin"), controllers.DeleteQuest())
	quests.PATCH("/:id", middleware.CheckUserType("Admin"), controllers.UpdateQuest())
	quests.PATCH("/IsCompleted/:questId", controllers.CompleteQuest())

	quests.PUT("/mental-habit/:id", controllers.EditMentalOrHabitQuest())
	quests.DELETE("/mental-habit/:id", controllers.DeleteMentalOrHabitQuest())
}
