package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
)

type Enemy struct {
	ID         bson.ObjectID `bson:"_id,omitempty" validate:"required"`
	Name       string        `bson:"name" validate:"required,min=1"`
	Stats      Stats         `bson:"stats" validate:"required,dive,gt=0"`
	IsDefeated bool          `bson:"is_defeated" validate:"required"`
}
