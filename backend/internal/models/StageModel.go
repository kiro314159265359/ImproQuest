package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
)

type Stage struct {
	ID            bson.ObjectID `json:"_id,omitempty" bson:"_id,omitempty" validate:"required"`
	Name          string        `json:"name" bson:"name" validate:"required,min=1,max=100"`
	Description   string        `json:"description" bson:"description"`
	Difficulty    string        `json:"difficulty" bson:"difficulty" validate:"required,oneof=Easy Medium Hard"`
	LevelRequired int           `json:"level_required" bson:"level_required" validate:"required,gte=0"`
	EnemyID       bson.ObjectID `json:"enemy_id" bson:"enemy_id" validate:"required"`
	XPReward      *float64      `json:"xp_reward" bson:"xp_reward" validate:"required,gte=0"`
	GoldReward    *float64      `json:"gold_reward" bson:"gold_reward" validate:"required,gte=0"`
}
