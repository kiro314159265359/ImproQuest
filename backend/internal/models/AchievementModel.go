package models

import (
	"go.mongodb.org/mongo-driver/v2/bson"
)

type Achievement struct {
	ID           bson.ObjectID `json:"_id,omitempty" bson:"_id,omitempty" validate:"omitempty"`
	Name         string        `json:"name" bson:"name" validate:"required,min=2,max=100"`
	Description  string        `json:"description" bson:"description" validate:"required,min=5,max=500"`
	Reward       string        `json:"reward" bson:"reward" validate:"required,min=2,max=200"`
	TriggerType  string        `json:"trigger_type" bson:"trigger_type" validate:"required,oneof=DISTANCE LEVEL STREAK QUESTS_COMPLETED"`
	TriggerValue float64       `json:"trigger_value" bson:"trigger_value" validate:"required,gte=0"`
}
