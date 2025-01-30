package routes

import (
	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/gin-gonic/gin"
)

func AuthRoutes(incomingRoutes *gin.Engine) {

	users := incomingRoutes.Group("/users")

	users.POST("/signup", controllers.Signup())
	users.POST("/login", controllers.Login())
	users.GET("/logout", controllers.Logout())
	users.PATCH("/:id/refresh", controllers.Refresh())
	users.GET("/auth/:provider", controllers.BeginAuthHandler)
	users.GET("/auth/:provider/callback", controllers.AuthCallbackHandler)

}
