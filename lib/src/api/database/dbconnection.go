package database

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/joho/godotenv"
	"go.mongodb.org/mongo-driver/v2/mongo"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

func DBinstance() *mongo.Client {
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}

	fmt.Println("Loaded environment variables successfully.")

	MongoDB := os.Getenv("MONGODB_URL")
	if MongoDB == "" {
		log.Fatal("MONGODB_URL environment variable not set")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client, err := mongo.Connect(options.Client().ApplyURI(MongoDB))
	if err != nil {
		log.Fatalf("failed to connect to server: %v", err)
	}

	// Ping the database to verify the connection
	if err := client.Ping(ctx, nil); err != nil {
		log.Fatalf("Failed to ping MongoDB: %v", err)
	}

	log.Println("Connected to MongoDB!")

	// Return the client so other parts of the application can use it
	return client
}

var Client *mongo.Client = DBinstance()

func OpenCollection(Client *mongo.Client, collectionName string) *mongo.Collection {
	var collection *mongo.Collection = Client.Database("App").Collection(collectionName)
	return collection
}
