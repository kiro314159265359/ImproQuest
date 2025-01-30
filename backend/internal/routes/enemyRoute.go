package routes

import (
	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/middleware"
	"github.com/gin-gonic/gin"
)

func EnemiesRoutes(router *gin.Engine) {
	adminRoutes := router.Group("/enemies")
	adminRoutes.Use(middleware.Authenticate())

	adminRoutes.GET("/", controllers.GetAllEnemies)
	adminRoutes.GET("/:enemyId", controllers.GetEnemyByID)

	adminRoutes.POST("/create", controllers.CreateEnemy)

	adminRoutes.PUT("/:enemyId", controllers.UpdateEnemy)

	adminRoutes.DELETE("/:enemyId", controllers.DeleteEnemy)
}
