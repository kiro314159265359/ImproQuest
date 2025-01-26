package models

import (
    "go.mongodb.org/mongo-driver/v2/bson"
)

type Enemy struct {
    ID         bson.ObjectID `json:"_id,omitempty" bson:"_id,omitempty" validate:"required"`
    Name       string        `json:"name" bson:"name" validate:"required,min=1"`
    Stats      Stats         `json:"stats" bson:"stats" validate:"required,dive,gt=0"`
    IsDefeated bool          `json:"is_defeated" bson:"is_defeated" validate:"required"`
}
