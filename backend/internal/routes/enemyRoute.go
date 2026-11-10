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

	adminRoutes.POST("/create", middleware.CheckUserType("Admin"), controllers.CreateEnemy)

	adminRoutes.PUT("/:enemyId", middleware.CheckUserType("Admin"), controllers.UpdateEnemy)

	adminRoutes.DELETE("/:enemyId", middleware.CheckUserType("Admin"), controllers.DeleteEnemy)
}
