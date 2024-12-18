package routes

import (
	"github.com/gin-gonic/gin"
	controller "github.com/HarDizzeR/Project/controllers"
	mid "github.com/HarDizzeR/Project/middleware"
)

func UserRoutes(incomingRoutes *gin.Engine) {

	users := incomingRoutes.Group("/users")

	users.Use(mid.Authenticate())

	users.GET("/", controller.GetUsers())
	users.GET("/:id", controller.GetUser())
}
