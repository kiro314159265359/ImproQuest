package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
)

type Stage struct {
	ID            bson.ObjectID `bson:"_id,omitempty" validate:"required"`
	Name          string        `bson:"name" validate:"required,min=1,max=100"` // E.g., "Forest Level"
	LevelRequired int           `bson:"level_required" validate:"required,gte=0"`
	EnemyID       bson.ObjectID `bson:"enemy_id" validate:"required"` // Reference to Enemy
}
