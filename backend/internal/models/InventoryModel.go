package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
)

type Inventory struct {
	ID     bson.ObjectID   `bson:"_id,omitempty" validate:"omitempty"`
	UserID bson.ObjectID   `bson:"user_id" validate:"required"`
	Items  []bson.ObjectID `bson:"items" validate:"dive,required"` // References to Item
	Gear   []bson.ObjectID `bson:"gear" validate:"dive,required"`  // References to Gear
}
