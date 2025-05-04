package models

import (
	"time"

	"go.mongodb.org/mongo-driver/v2/bson"
)

type Run struct {
	ID        bson.ObjectID `bson:"_id,omitempty" json:"id,omitempty"`                // omitempty prevents sending zero value (empty ObjectID) on creation
	UserID    bson.ObjectID `bson:"userId" json:"userId"`                             // Link to the user
	Distance  float64       `bson:"distance" json:"distance" binding:"required,gt=0"` // Distance run, added validation tags
	Date      time.Time     `bson:"date" json:"date" binding:"required"`              // Date of the run
	CreatedAt time.Time     `bson:"createdAt" json:"createdAt"`
	UpdatedAt time.Time     `bson:"updatedAt" json:"updatedAt"`
}

type CreateRunRequest struct {
	UserID   string    `json:"userId" binding:"required"`
	Distance float64   `json:"distance" binding:"required,gt=0"`
	Date     time.Time `json:"date" binding:"required"`
}

type HistogramDataPoint struct {
	Period        string  `json:"period" bson:"_id"`
	TotalDistance float64 `json:"totalDistance" bson:"totalDistance"`
}
