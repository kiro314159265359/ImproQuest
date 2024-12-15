package main

import (
	"fmt"
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	routes "kiro.com/routes"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}

	fmt.Println("Loaded environment variables successfully.")

	port := os.Getenv("PORT")
	mongodbURL := os.Getenv("MONGODB_URL")

	fmt.Println("PORT:", port)
	fmt.Println("MONGODB_URL:", mongodbURL)

	if port == "" {
		port = "8000"
	}

	if mongodbURL == "" {
		log.Fatal("MONGODB_URL environment variable not set")
	}

	router := gin.New()
	router.Use(gin.Logger())

	routes.AuthRoutes(router)
	routes.UserRoutes(router)

	router.GET("/api-1", func(c *gin.Context) {
		c.JSON(200, gin.H{"success": "Access granted for api-1"})
	})
	router.GET("/api-2", func(c *gin.Context) {
		c.JSON(200, gin.H{"success": "Access granted for api-2"})
	})
	router.Run(":" + port)
}
