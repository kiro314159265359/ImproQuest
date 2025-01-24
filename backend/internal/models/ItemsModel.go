package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
)

type Item struct {
	ID     bson.ObjectID `bson:"_id,omitempty" validate:"required"`
	Name   string        `bson:"name" validate:"required,min=2,max=100"`
	Type   string        `bson:"type" validate:"required,oneof=consumable collectible"`
	Effect string        `bson:"effect" validate:"required,min=1,max=200"`
	Price  float64       `bson:"price" validate:"required,gte=0"`
}
