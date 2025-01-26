package models

import (
    "go.mongodb.org/mongo-driver/v2/bson"
)

type Stage struct {
    ID            bson.ObjectID `json:"_id,omitempty" bson:"_id,omitempty" validate:"required"`
    Name          string        `json:"name" bson:"name" validate:"required,min=1,max=100"`
    LevelRequired int           `json:"level_required" bson:"level_required" validate:"required,gte=0"`
    EnemyID       bson.ObjectID `json:"enemy_id" bson:"enemy_id" validate:"required"`
}
