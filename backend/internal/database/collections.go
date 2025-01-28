package database

import (
	"go.mongodb.org/mongo-driver/v2/mongo"
)

var (
	usersCollection   *mongo.Collection
	questsCollection  *mongo.Collection
	itemsCollection   *mongo.Collection
	stagesCollection  *mongo.Collection
	enemiesCollection *mongo.Collection
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

func Items() *mongo.Collection {
	if Client == nil {
		panic("database client not initialized")
	}

	if itemsCollection == nil {
		itemsCollection = Client.Database("App").Collection("Items")
	}
	return itemsCollection
}

func Stages() *mongo.Collection {
	if Client == nil {
		panic("database client not initialized")
	}
	if stagesCollection == nil {
		stagesCollection = Client.Database("App").Collection("Stages")
	}
	return stagesCollection
}

func Enemies() *mongo.Collection {
	if Client == nil {
		panic("database client not initialized")
	}
	if enemiesCollection == nil {
		enemiesCollection = Client.Database("App").Collection("Enemies")
	}
	return enemiesCollection
}
