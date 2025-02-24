package models

import (
	"time"

	"go.mongodb.org/mongo-driver/v2/bson"
)

type Quest struct {
	ID          bson.ObjectID `json:"_id,omitempty" bson:"_id,omitempty" validate:"omitempty"`
	Name        *string       `json:"name" bson:"name" validate:"required,min=3,max=100"`
	Goal        *float64      `json:"goal" bson:"goal"`
	XPReward    *float64      `json:"xp_reward" bson:"xp_reward" validate:"required,gte=0"`
	GoldReward  *float64      `json:"gold_reward" bson:"gold_reward" validate:"required,gte=0"`
	Difficulty  *string       `json:"difficulty" bson:"difficulty" validate:"required,oneof=Easy Medium Hard"`
	IsCompleted bool          `json:"is_completed" bson:"is_completed"`
	GivenAt     time.Time     `json:"given_at" bson:"given_at"`
}
