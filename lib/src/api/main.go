package main

import (
	"fmt"
	"log"
	"os"

	routes "github.com/HarDizzeR/Project/routes"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
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

	router.Run(":" + port)
}
