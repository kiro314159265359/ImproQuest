package models

import (
	"time"

	"go.mongodb.org/mongo-driver/v2/bson"
)

type User struct {
	ID            bson.ObjectID `bson:"_id,omitempty"`
	UserName      *string            `json:"UserName" validate:"required,min=2,max=200"`
	Email         *string            `json:"Email" validate:"email,required"`
	Password      *string            `json:"Password" validate:"required,min=6"`
	Height        *float64           `json:"Height" validate:"required,min=50,max=250"`
	Token         *string            `json:"Token,omitempty"`
	Gender        *string            `json:"Gender" validate:"required"`
	UserType      *string            `json:"UserType" validate:"required,oneof=ADMIN USER"`
	Refresh_token *string            `json:"Refresh_token,omitempty"`
	BirthDate     time.Time          `json:"BirthDate"`
	Weight        *float64           `json:"Weight" validate:"required,min=50,max=200"`
	Created_at    time.Time          `json:"Created_at"`
	Updated_at    time.Time          `json:"Updated_at"`
}
