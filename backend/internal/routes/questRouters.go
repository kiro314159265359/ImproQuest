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
	quests.POST("/", controllers.CreateQuest())
	quests.GET("/:id", controllers.GetQuest())
	quests.DELETE("/:id", controllers.DeleteQuest())
	quests.PATCH("/:id", controllers.UpdateQuest())

}
