package models

import (
	"time"

	"go.mongodb.org/mongo-driver/v2/bson"
)

type Quest struct {
	ID           bson.ObjectID `bson:"_id,omitempty" validate:"omitempty"`
	UserID       bson.ObjectID `bson:"user_id" validate:"required"`
	Name         string        `bson:"name" validate:"required,min=3,max=100"` // E.g., "Run 1km"
	XPReward     float64       `bson:"xp_reward" validate:"required,gte=0"`
	GoldReward   float64       `bson:"gold_reward" validate:"required,gte=0"`
	Difficulty   string        `bson:"difficulty" validate:"required,oneof=easy medium hard"` // "easy", "medium", "hard"
	IsCompleted  bool          `bson:"is_completed" validate:"required"`
	DateAssigned time.Time     `bson:"date_assigned" validate:"required"`
}
