package routes

import (
	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/middleware"
	"github.com/gin-gonic/gin"
)

func EnemiesRoutes(router *gin.Engine) {
	adminRoutes := router.Group("/Enemies")
	adminRoutes.Use(middleware.Authenticate())

	adminRoutes.POST("/create", controllers.CreateEnemy)

	adminRoutes.GET("/", controllers.GetAllEnemies)
	adminRoutes.GET("/:enemyId", controllers.GetEnemyByID)

	adminRoutes.PUT("/:enemyId", controllers.UpdateEnemy)

	adminRoutes.DELETE("/:enemyId", controllers.DeleteEnemy)
}
