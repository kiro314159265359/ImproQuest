package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
	"time"
)

type Achievement struct {
	ID          bson.ObjectID `json:"_id,omitempty" bson:"_id,omitempty" validate:"omitempty"`
	Name        string        `json:"name" bson:"name" validate:"required,min=2,max=100"`
	Description string        `json:"description" bson:"description" validate:"required,min=5,max=500"`
	Reward      string        `json:"reward" bson:"reward" validate:"required,min=2,max=200"`
	DateEarned  time.Time     `json:"date_earned" bson:"date_earned" validate:"required"`
}
