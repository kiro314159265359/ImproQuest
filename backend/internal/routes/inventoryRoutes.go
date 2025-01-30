package routes

import (
	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/middleware"
	"github.com/gin-gonic/gin"
)

func InventoryRoutes(incomingRoutes *gin.Engine) {
	inventory := incomingRoutes.Group("/inventory")
	inventory.Use(middleware.Authenticate())

	inventory.GET("/inventories", controllers.GetAllInventories)
	inventory.GET("/:id", controllers.GetInventoryByID)

	inventory.POST("/add/:id", controllers.AddInventory)

	inventory.PUT("/:id", controllers.UpdateInventorySize)
	inventory.DELETE("/:id", controllers.DeleteInventoryByUserID)
}
