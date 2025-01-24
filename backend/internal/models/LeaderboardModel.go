package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
	"time"
)

type Leaderboard struct {
	ID        bson.ObjectID      `bson:"_id,omitempty" validate:"required"`
	Entries   []LeaderboardEntry `bson:"entries" validate:"dive"`
	UpdatedAt time.Time          `bson:"updated_at" validate:"required"`
}

type LeaderboardEntry struct {
	UserID bson.ObjectID `bson:"user_id" validate:"required"`
	XP     float64       `bson:"xp" validate:"required,gte=0"`
	Level  int           `bson:"level" validate:"required,gte=1"`
	Rank   int           `bson:"rank" validate:"required,gte=1"`
}
