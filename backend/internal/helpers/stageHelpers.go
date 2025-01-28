package helpers

import (
	"context"

	"github.com/HarDizzeR/Project/backend/internal/database"

	"go.mongodb.org/mongo-driver/v2/bson"
)

func IsValidEnemy(enemyID bson.ObjectID) bool {
	ctx := context.TODO()
	enemiesCollection := database.Enemies()

	var enemy struct{}
	err := enemiesCollection.FindOne(ctx, bson.M{"_id": enemyID}).Decode(&enemy)
	return err == nil
}
