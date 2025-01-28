package routes

import (
	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/middleware"
	"github.com/gin-gonic/gin"
)

func ItemRoutes(router *gin.Engine) {
	items := router.Group("/items")
	items.Use(middleware.Authenticate())

	items.POST("/Create", controllers.CreateItem)
	items.PUT("/Update/:itemId", controllers.UpdateItem)

	items.POST("/:itemId/add", controllers.AddItem)
	items.DELETE("/:itemId/remove", controllers.RemoveItem)

}
