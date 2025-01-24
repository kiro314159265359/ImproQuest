package database

import (
	"go.mongodb.org/mongo-driver/v2/mongo"
)

var (
    usersCollection *mongo.Collection
)

func Users() *mongo.Collection {
    if Client == nil {
        panic("database client not initialized")
    }
    if usersCollection == nil {
        usersCollection = Client.Database("App").Collection("users")
    }
    return usersCollection
}