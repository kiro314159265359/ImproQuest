package main

import (
	"fmt"
	"os"
	"time"

	controllers "github.com/HarDizzeR/Project/backend/internal/controllers"
	logger "github.com/HarDizzeR/Project/backend/internal/logger"
	routes "github.com/HarDizzeR/Project/backend/internal/routes"
	helpers "github.com/HarDizzeR/Project/backend/internal/helpers"

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

	router.Run(":" + port)
}
