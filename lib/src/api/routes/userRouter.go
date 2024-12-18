package routes

import (
	controller "github.com/HarDizzeR/Project/controllers"
	mid "github.com/HarDizzeR/Project/middleware"
	"github.com/gin-gonic/gin"
)

func UserRoutes(incomingRoutes *gin.Engine) {

	users := incomingRoutes.Group("/users")

	users.Use(mid.Authenticate())

	users.GET("/", controller.GetUsers())
	users.GET("/:id", controller.GetUser())
	users.DELETE("/delete/:id", controller.DeleteUser())
	users.PATCH("/update/:id", controller.UpdateUser())
}
