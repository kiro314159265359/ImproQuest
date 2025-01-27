package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
)

type Inventory struct {
	ID     bson.ObjectID   `json:"_id,omitempty" bson:"_id,omitempty" validate:"omitempty"`
	UserID bson.ObjectID   `json:"user_id" bson:"user_id" validate:"required"`
	Items  []bson.ObjectID `json:"items" bson:"items" validate:"dive,required"`
	Gear   []bson.ObjectID `json:"gear" bson:"gear" validate:"dive,required"`
	Size   int             `json:"size" bson:"size" validate:"required,gte=0"`
}
