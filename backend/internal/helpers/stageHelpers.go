package helpers

import (
	"context"

	"github.com/HarDizzeR/Project/backend/internal/database"

	"go.mongodb.org/mongo-driver/v2/bson"
)

func IsValidEnemy(enemyID string) bool {
	// Convert the string ID to bson.ObjectID
	objID, err := bson.ObjectIDFromHex(enemyID)
	if err != nil {
		return false
	}

	// Check if the enemy exists in the database
	ctx := context.TODO()
	filter := bson.M{"_id": objID}
	count, err := database.Enemies().CountDocuments(ctx, filter)
	if err != nil || count == 0 {
		return false
	}

	return true
}
