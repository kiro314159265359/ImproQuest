package routes

import (
	controllers "github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/gin-gonic/gin"
)

func AuthRoutes(incomingRoutes *gin.Engine) {

	users := incomingRoutes.Group("/users")

	users.POST("/signup", controllers.Signup())
	users.POST("/login", controllers.Login())
	users.GET("/auth/:provider", controllers.BeginAuthHandler)
	users.GET("/auth/:provider/callback", controllers.AuthCallbackHandler)
}
