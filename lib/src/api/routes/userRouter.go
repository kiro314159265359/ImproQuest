package routes

import (
	"github.com/gin-gonic/gin"
	controller "kiro.com/controllers"
	mid "kiro.com/middleware"
)

func UserRoutes(incomingRoutes *gin.Engine) {

	users := incomingRoutes.Group("/users")

	users.Use(mid.Authenticate())

	users.GET("/", controller.GetUsers())
	users.GET("/:User_id", controller.GetUser())
}
