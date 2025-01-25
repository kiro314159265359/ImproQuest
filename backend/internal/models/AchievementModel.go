package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
	"time"
)

type Achievement struct {
	ID          bson.ObjectID `bson:"_id,omitempty" validate:"omitempty"`
	// UserID      bson.ObjectID `bson:"user_id" validate:"required"`
	Name        string        `bson:"name" validate:"required,min=2,max=100"`
	Description string        `bson:"description" validate:"required,min=5,max=500"`
	Reward      string        `bson:"reward" validate:"required,min=2,max=200"`
	DateEarned  time.Time     `bson:"date_earned" validate:"required"`
}
