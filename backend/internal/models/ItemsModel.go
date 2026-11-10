package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
)

type Item struct {
	ID          bson.ObjectID `json:"_id,omitempty" bson:"_id,omitempty" validate:"required"`
	Name        string        `json:"name" bson:"name" validate:"required,min=2,max=100"`
	Type        string        `json:"type" bson:"type" validate:"required,oneof=consumable collectible equipment"`
	Slot        string        `json:"slot,omitempty" bson:"slot,omitempty" validate:"omitempty,oneof=helmet chestplate leggings boots weapon"`
	Description string        `json:"description" bson:"description" validate:"required,min=1,max=500"`
	IsPermanent bool          `json:"is_permanent" bson:"is_permanent"`
	Price       float64       `json:"price" bson:"price" validate:"required,gte=0"`
	StatBonuses *Stats        `json:"stat_bonuses,omitempty" bson:"stat_bonuses,omitempty"`
	Effects     *ItemEffects  `json:"effects,omitempty" bson:"effects,omitempty"`
}

type ItemEffects struct {
	Vitality  float64 `json:"Vitality,omitempty" bson:"Vitality,omitempty"`
	Strength  float64 `json:"strength,omitempty" bson:"strength,omitempty"`
	Endurance float64 `json:"endurance,omitempty" bson:"endurance,omitempty"`
	Agility   float64 `json:"agility,omitempty" bson:"agility,omitempty"`
	Duration  int     `json:"duration,omitempty" bson:"duration,omitempty"` // Duration in seconds
}
