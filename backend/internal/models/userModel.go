package models

import (
	"time"

	"go.mongodb.org/mongo-driver/v2/bson"
)

type Streak struct {
	ID            bson.ObjectID `bson:"_id,omitempty"`
	Current       int           `bson:"current" validate:"gte=0"`
	HighestStreak time.Time     `bson:"highest_streak" validate:"required"`
}

type User struct {
	ID            bson.ObjectID   `bson:"_id,omitempty"`
	Username      *string         `bson:"username" validate:"required,min=2,max=200"`
	Email         *string         `bson:"email" validate:"required,email"`
	Password      *string         `bson:"password" validate:"required,min=8"`
	Height        *float64        `bson:"height" validate:"required,min=50,max=300"`
	Token         *string         `bson:"token,omitempty"`
	Gender        *string         `bson:"gender" validate:"required,oneof=male female"`
	UserType      *string         `bson:"user_type" validate:"required,oneof=ADMIN USER"`
	Refresh_token *string         `bson:"refresh_token,omitempty"`
	BirthDate     time.Time       `bson:"birth_date" validate:"required,ltefield=Created_at"`
	Weight        *float64        `bson:"weight" validate:"required,min=30,max=300"`
	XP            float64         `bson:"xp" validate:"gte=0"`
	Level         int             `bson:"level" validate:"gte=1"`
	Gold          float64         `bson:"gold" validate:"gte=0"`
	Streak        Streak          `bson:"streak" validate:"required"`
	InventoryID   bson.ObjectID   `bson:"inventory_id" validate:"required"`
	Achievements  []bson.ObjectID `bson:"achievements" validate:"dive,required"`
	CurrentQuests []bson.ObjectID `bson:"current_quests" validate:"dive,required"`
	Stats         Stats           `bson:"stats" validate:"required"`
	AccumDistance float64         `bson:"accum_distance" validate:"gte=0"`
	Created_at    time.Time       `bson:"Created_at" validate:"required"`
	Updated_at    time.Time       `bson:"Updated_at" validate:"required,gtefield=Created_at"`
}
