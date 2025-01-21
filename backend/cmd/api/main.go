package main

import (
	"fmt"
	"os"
	"time"

	logger "github.com/HarDizzeR/Project/backend/internal/logger"
	routes "github.com/HarDizzeR/Project/backend/internal/routes"
	controllers "github.com/HarDizzeR/Project/backend/internal/controllers"

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
		logger.Fatal("Error loading .env file: %v", zap.Error(err))
	}

	controllers.InitAuthProviders()
	controllers.InitSessionStore()

	fmt.Println("Loaded environment variables successfully.")

	port := os.Getenv("PORT")
	mongodbURL := os.Getenv("MONGODB_URL")

	fmt.Println("PORT:", port)
	fmt.Println("MONGODB_URL:", mongodbURL)

	if port == "" {
		port = "8000"
	}

	if mongodbURL == "" {
		logger.Fatal("MONGODB_URL environment variable not set")
	}

	router := gin.New()
	router.Use(ginzap.Ginzap(logger, time.RFC3339, true))
	router.Use(ginzap.RecoveryWithZap(logger, true))

	routes.AuthRoutes(router)
	routes.UserRoutes(router)

	router.Run(":" + port)
}
