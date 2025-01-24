package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
)

type Gear struct {
	ID            bson.ObjectID `bson:"_id,omitempty" validate:"required"`
	Name          string        `bson:"name" validate:"required,min=1,max=100"`
	Type          string        `bson:"type" validate:"required,oneof=helmet chestplate leggings boots"`
	StatBonuses   Stats         `bson:"stat_bonuses" validate:"required,dive,keys,endkeys"`
	Price         float64       `bson:"price" validate:"required,gte=0"`
	LevelRequired int           `bson:"level_required" validate:"required,gte=1"`
}
