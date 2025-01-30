package routes

import (
	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/middleware"
	"github.com/gin-gonic/gin"
)

func GearRoutes(incomingRoutes *gin.Engine) {
	gears := incomingRoutes.Group("/gears")
	gears.Use(middleware.Authenticate())

	// admin routes here
	gears.POST("/create", controllers.CreateGear)
	gears.GET("/", controllers.GetAllGears)
	gears.GET("/:id", controllers.GetGearByID)
	gears.DELETE("/:id", controllers.DeleteGear)
	gears.PATCH("/:id", controllers.UpdateGear)
	// user routes here
	gears.POST("/add/:id", controllers.AddGear)
	gears.DELETE("/remove/:id", controllers.RemoveGear)
}
