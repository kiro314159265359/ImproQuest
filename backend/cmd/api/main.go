package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/HarDizzeR/Project/backend/internal/controllers"
	"github.com/HarDizzeR/Project/backend/internal/database"
	"github.com/HarDizzeR/Project/backend/internal/helpers"
	"github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/HarDizzeR/Project/backend/internal/models"
	"github.com/HarDizzeR/Project/backend/internal/routes"
	"github.com/HarDizzeR/Project/backend/internal/services"

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

	database.DBinstance()
	database.InitRunsCollection()

	runModel := models.NewRunModel()
	runController := controllers.NewRunController(runModel)
	wsManager := services.NewWebSocketManager(runModel)

	fmt.Println("Loaded environment variables successfully.")

	router := gin.New()
	router.Use(ginzap.Ginzap(logger, time.RFC3339, true))
	router.Use(ginzap.RecoveryWithZap(logger, true))

	routes.AuthRoutes(router)
	routes.UserRoutes(router)
	routes.QuestRoutes(router)
	routes.StageRoutes(router)
	routes.EnemiesRoutes(router)
	routes.AchievementRoutes(router)
	routes.InventoryRoutes(router)
	routes.LeaderboardRoutes(router)
	routes.ShopRoutes(router)

	routes.SetupRunRoutes(router, runController, wsManager)
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "up"})
	})

	// Start server with graceful shutdown
	port := os.Getenv("PORT")
	if port == "" {
		port = "8000"
	}
	srv := &http.Server{Addr: ":" + port, Handler: router}

	go func() {
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed: %v", err)
		}
	}()

	log.Printf("Server running on port %s", port)

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down server...")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}
	log.Println("Server exited properly")
}
