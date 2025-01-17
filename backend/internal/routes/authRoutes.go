package routes

import (
	"github.com/gin-gonic/gin"
	controller "github.com/HarDizzeR/Project/internal/controllers"
)

func AuthRoutes(incomingRoutes *gin.Engine) {

	users := incomingRoutes.Group("/users")

	users.POST("/signup", controller.Signup())
	users.POST("/login", controller.Login())

}
