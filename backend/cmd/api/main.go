package main

import (
	"fmt"
	"os"
	"time"

	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/helpers"
	"github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/HarDizzeR/Project/backend/internal/routes"

	ginzap "github.com/gin-contrib/zap"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"go.uber.org/zap"
)

func main() {

	logger := logger.InitLogger()
	defer logger.Sync()

	logger.Info("Starting application")

	err := godotenv.Load("config/.env")
	if err != nil {
		logger.Fatal("Error loading .env file", zap.Error(err))
	}

	// Initialize security configuration
	if err := helpers.InitSecurityConfig(); err != nil {
		logger.Fatal("Failed to initialize security configuration", zap.Error(err))
	}

	controllers.InitAuthProviders()
	controllers.InitSessionStore()

	fmt.Println("Loaded environment variables successfully.")

	port := os.Getenv("PORT")

	if port == "" {
		port = "8000"
	}

	router := gin.New()
	router.Use(ginzap.Ginzap(logger, time.RFC3339, true))
	router.Use(ginzap.RecoveryWithZap(logger, true))

	routes.AuthRoutes(router)
	routes.UserRoutes(router)
	routes.QuestRoutes(router)
	routes.ItemRoutes(router)
	routes.StageRoutes(router)
	routes.EnemiesRoutes(router)
	routes.AchievementRoutes(router)
	router.Run(":" + port)
}
