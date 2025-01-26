package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
)

type Item struct {
	ID     bson.ObjectID `json:"_id,omitempty" bson:"_id,omitempty" validate:"required"`
	Name   string        `json:"name" bson:"name" validate:"required,min=2,max=100"`
	Type   string        `json:"type" bson:"type" validate:"required,oneof=consumable collectible"`
	Effect string        `json:"effect" bson:"effect" validate:"required,min=1,max=200"`
	Price  float64       `json:"price" bson:"price" validate:"required,gte=0"`
}
