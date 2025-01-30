package routes

import (
	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/middleware"
	"github.com/gin-gonic/gin"
)

func ItemRoutes(router *gin.Engine) {
	items := router.Group("/items")
	items.Use(middleware.Authenticate())

	items.GET("/", controllers.GetAllItems)
	items.GET("/:itemId", controllers.GetItemById)

	items.PUT("/Update/:itemId", controllers.UpdateItem)

	items.POST("/Create", controllers.CreateItem)
	items.POST("/:itemId/add", controllers.AddItemToInventory)

	items.DELETE("/:itemId/remove", controllers.RemoveItemFromInventory)
	items.DELETE("/:itemId/delete", controllers.DeleteItem)
}
