package routes

import (
	"github.com/gin-gonic/gin"
	controller "kiro.com/controllers"
)

func AuthRoutes(incomingRoutes *gin.Engine) {

	users := incomingRoutes.Group("/users")

	users.POST("/signup", controller.Signup())
	users.POST("/login", controller.Login())

}
