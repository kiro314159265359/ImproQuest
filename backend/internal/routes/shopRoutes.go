package routes

import (
	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/middleware"
	"github.com/gin-gonic/gin"
)

func ShopRoutes(router *gin.Engine) {
	shop := router.Group("/shop")
	shop.Use(middleware.Authenticate())

	// Permanent items endpoints
	shop.GET("/permanent", controllers.GetPermanentItems)
	shop.POST("/permanent", middleware.CheckUserType("Admin"), controllers.CreatePermanentItem)
	shop.PUT("/permanent/:itemId", middleware.CheckUserType("Admin"), controllers.UpdatePermanentItem)
	shop.DELETE("/permanent/:itemId", middleware.CheckUserType("Admin"), controllers.DeletePermanentItem)

	// Consumable items endpoints
	shop.GET("/consumables", controllers.GetConsumableItems)
	shop.POST("/consumables", middleware.CheckUserType("Admin"), controllers.CreateConsumableItem)
	shop.PUT("/consumables/:itemId", middleware.CheckUserType("Admin"), controllers.UpdateConsumableItem)
	shop.DELETE("/consumables/:itemId", middleware.CheckUserType("Admin"), controllers.DeleteConsumableItem)

	shop.POST("/buy/:itemId", controllers.AddItemToInventory)
}
