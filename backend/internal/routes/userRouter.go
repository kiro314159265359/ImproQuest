package routes

import (
	controller "github.com/HarDizzeR/Project/internal/controllers"
	mid "github.com/HarDizzeR/Project/internal/middleware"
	"github.com/gin-gonic/gin"
)

func UserRoutes(incomingRoutes *gin.Engine) {

	users := incomingRoutes.Group("/users")

	users.Use(mid.Authenticate())

	users.GET("/", controller.GetUsers())
	users.GET("/:id", controller.GetUser())
	users.DELETE("/:id", controller.DeleteUser())
	users.PATCH("/:id", controller.UpdateUser())
}
