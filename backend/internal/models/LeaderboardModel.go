package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
	"time"
)

type Leaderboard struct {
	ID        bson.ObjectID      `json:"_id,omitempty" bson:"_id,omitempty" validate:"required"`
	Entries   []LeaderboardEntry `json:"entries" bson:"entries" validate:"dive"`
	UpdatedAt time.Time          `json:"updated_at" bson:"updated_at" validate:"required"`
}

type LeaderboardEntry struct {
	UserID bson.ObjectID `json:"user_id" bson:"user_id" validate:"required"`
	XP     float64       `json:"xp" bson:"xp" validate:"required,gte=0"`
	Level  int           `json:"level" bson:"level" validate:"required,gte=1"`
	Rank   int           `json:"rank" bson:"rank" validate:"required,gte=1"`
}
