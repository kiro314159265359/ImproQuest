package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
)

type Enemy struct {
	ID         bson.ObjectID `json:"id" bson:"_id,omitempty"`
	Name       string        `json:"name" bson:"name" validate:"required"`
	Level      int           `json:"level" bson:"level" validate:"required,gte=1,lte=100"`
	Stats      Stats         `json:"stats" bson:"stats" validate:"required"`
	IsDefeated bool          `json:"is_defeated" bson:"is_defeated"`
}
