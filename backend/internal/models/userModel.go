package models

import (
	"time"

	"go.mongodb.org/mongo-driver/v2/bson"
)

type Streak struct {
	ID            bson.ObjectID `json:"_id,omitempty" bson:"_id,omitempty"`
	Current       int           `json:"current" bson:"current" validate:"gte=0"`
	HighestCount  int           `json:"highest_count" bson:"highest_count" validate:"gte=0"`
	LastCompleted time.Time     `bson:"last_completed" json:"last_completed" validate:"required"`
}

type User struct {
	ID            bson.ObjectID   `json:"_id,omitempty" bson:"_id,omitempty"`
	Username      *string         `json:"username" bson:"username" validate:"required,min=2,max=200"`
	MobileNumber  *string         `json:"mobile_number" bson:"mobile_number"`
	Email         *string         `json:"email" bson:"email" validate:"required,email"`
	Password      *string         `json:"-" bson:"password" validate:"required,min=8"`
	Height        *float64        `json:"height" bson:"height" validate:"required,min=50,max=300"`
	Gender        *string         `json:"gender" bson:"gender" validate:"required,oneof=Male Female"`
	UserType      *string         `json:"user_type" bson:"user_type" validate:"required,oneof=Admin User"`
	Token         *string         `json:"-" bson:"token,omitempty"`
	Refresh_token *string         `json:"-" bson:"refresh_token,omitempty"`
	BirthDate     time.Time       `json:"birth_date" bson:"birth_date" validate:"required"`
	Weight        *float64        `json:"weight" bson:"weight" validate:"required,min=30,max=300"`
	XP            float64         `json:"xp" bson:"xp" validate:"gte=0"`
	Level         int             `json:"level" bson:"level" validate:"gte=1"`
	Gold          float64         `json:"gold" bson:"gold" validate:"gte=0"`
	Streak        Streak          `json:"streak" bson:"streak" validate:"required"`
	InventoryID   bson.ObjectID   `json:"inventory_id" bson:"inventory_id" validate:"required"`      // Reference to Inventory
	Achievements  []bson.ObjectID `json:"achievements" bson:"achievements" validate:"dive,required"` // Reference to Achievements
	CurrentQuests []Quest         `json:"current_quests" bson:"quests" validate:"dive,required"`     // Embedded Quests
	Stats         Stats           `json:"stats" bson:"stats" validate:"required"`
	AccumDistance float64         `json:"accum_distance" bson:"accum_distance" validate:"gte=0"`
	Created_at    time.Time       `json:"created_at" bson:"Created_at" validate:"required"`
	Updated_at    time.Time       `json:"updated_at" bson:"Updated_at" validate:"required,gtefield=Created_at"`
}
