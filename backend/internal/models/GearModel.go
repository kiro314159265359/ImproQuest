package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
)

type Gear struct {
	ID            bson.ObjectID `json:"_id,omitempty" bson:"_id,omitempty" validate:"required"`
	Name          string        `json:"name" bson:"name" validate:"required,min=1,max=100"`
	Type          string        `json:"type" bson:"type" validate:"required,oneof=helmet chestplate leggings boots"`
	StatBonuses   Stats         `json:"stat_bonuses" bson:"stat_bonuses" validate:"required,dive,keys,endkeys"`
	Price         float64       `json:"price" bson:"price" validate:"required,gte=0"`
	LevelRequired int           `json:"level_required" bson:"level_required" validate:"required,gte=1"`
}
