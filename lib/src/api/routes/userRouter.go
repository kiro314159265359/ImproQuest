package routes

import (
	"github.com/gin-gonic/gin"
	controller "kiro.com/controllers"
	"kiro.com/middleware"
)

func UserRoutes(incomingRoutes *gin.Engine) {

	users := incomingRoutes.Group("/users")

	users.Use(middleware.Authenticate())
	users.GET("/", controller.GetUsers())
	users.GET("/:User_id", controller.GetUser())
}
