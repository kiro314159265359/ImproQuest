package database

import (
	"go.mongodb.org/mongo-driver/v2/mongo"
)

var (
	usersCollection *mongo.Collection
	questsCollection *mongo.Collection
)

func Users() *mongo.Collection {
	if Client == nil {
		panic("database client not initialized")
	}
	if usersCollection == nil {
		usersCollection = Client.Database("App").Collection("Users")
	}
	return usersCollection
}

func Quests() *mongo.Collection {
	if Client == nil {
		panic("database client not initialized")
	}
	if questsCollection == nil {
		questsCollection = Client.Database("App").Collection("Quests")
	}
	return questsCollection
}