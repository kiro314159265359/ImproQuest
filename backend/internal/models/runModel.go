package models

import (
	"context"
	"time"

	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"

	"github.com/HarDizzeR/Project/backend/internal/database" // Replace with your actual import path
)

// RunData represents a user's run data
type RunData struct {
	UserID    string    `json:"userId" bson:"userId"`
	Distance  float64   `json:"distance" bson:"distance"` // in meters
	Timestamp time.Time `json:"timestamp" bson:"timestamp"`
}

// HistogramData represents aggregated run data for histograms
type HistogramData struct {
	Date     time.Time `json:"date" bson:"_id"`
	Distance float64   `json:"distance" bson:"totalDistance"`
	Count    int       `json:"count" bson:"count"`
}

// RunModel handles run data operations
type RunModel struct {
	collection *mongo.Collection
}

// NewRunModel creates a new run model
func NewRunModel() *RunModel {
	return &RunModel{
		collection: database.Runs(),
	}
}

// SaveRun saves a run record to the database
func (m *RunModel) SaveRun(run *RunData) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// Set timestamp if not provided
	if run.Timestamp.IsZero() {
		run.Timestamp = time.Now()
	}

	_, err := m.collection.InsertOne(ctx, run)
	return err
}

// GetDailyHistogram gets daily histogram data for a user
func (m *RunModel) GetDailyHistogram(userID string, startDate, endDate time.Time) ([]HistogramData, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Create pipeline for aggregation
	pipeline := []bson.M{
		{
			"$match": bson.M{
				"userId": userID,
				"timestamp": bson.M{
					"$gte": startDate,
					"$lte": endDate,
				},
			},
		},
		{
			"$group": bson.M{
				"_id": bson.M{
					"$dateTrunc": bson.M{
						"date": "$timestamp",
						"unit": "day",
					},
				},
				"totalDistance": bson.M{"$sum": "$distance"},
				"count":         bson.M{"$sum": 1},
			},
		},
		{
			"$sort": bson.M{"_id": 1},
		},
	}

	cursor, err := m.collection.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var results []HistogramData
	if err = cursor.All(ctx, &results); err != nil {
		return nil, err
	}

	return results, nil
}

// GetWeeklyHistogram gets weekly histogram data for a user
func (m *RunModel) GetWeeklyHistogram(userID string, startDate, endDate time.Time) ([]HistogramData, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Create pipeline for aggregation
	pipeline := []bson.M{
		{
			"$match": bson.M{
				"userId": userID,
				"timestamp": bson.M{
					"$gte": startDate,
					"$lte": endDate,
				},
			},
		},
		{
			"$group": bson.M{
				"_id": bson.M{
					"$dateTrunc": bson.M{
						"date": "$timestamp",
						"unit": "week",
					},
				},
				"totalDistance": bson.M{"$sum": "$distance"},
				"count":         bson.M{"$sum": 1},
			},
		},
		{
			"$sort": bson.M{"_id": 1},
		},
	}

	cursor, err := m.collection.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var results []HistogramData
	if err = cursor.All(ctx, &results); err != nil {
		return nil, err
	}

	return results, nil
}

// GetMonthlyHistogram gets monthly histogram data for a user
func (m *RunModel) GetMonthlyHistogram(userID string, startDate, endDate time.Time) ([]HistogramData, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Create pipeline for aggregation
	pipeline := []bson.M{
		{
			"$match": bson.M{
				"userId": userID,
				"timestamp": bson.M{
					"$gte": startDate,
					"$lte": endDate,
				},
			},
		},
		{
			"$group": bson.M{
				"_id": bson.M{
					"$dateTrunc": bson.M{
						"date": "$timestamp",
						"unit": "month",
					},
				},
				"totalDistance": bson.M{"$sum": "$distance"},
				"count":         bson.M{"$sum": 1},
			},
		},
		{
			"$sort": bson.M{"_id": 1},
		},
	}

	cursor, err := m.collection.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var results []HistogramData
	if err = cursor.All(ctx, &results); err != nil {
		return nil, err
	}

	return results, nil
}

// GetTotalStats gets total stats for a user
func (m *RunModel) GetTotalStats(userID string) (map[string]interface{}, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	pipeline := []bson.M{
		{
			"$match": bson.M{
				"userId": userID,
			},
		},
		{
			"$group": bson.M{
				"_id":           nil,
				"totalDistance": bson.M{"$sum": "$distance"},
				"totalRuns":     bson.M{"$sum": 1},
				"firstRun":      bson.M{"$min": "$timestamp"},
				"lastRun":       bson.M{"$max": "$timestamp"},
			},
		},
	}

	cursor, err := m.collection.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var results []bson.M
	if err = cursor.All(ctx, &results); err != nil {
		return nil, err
	}

	if len(results) == 0 {
		return map[string]interface{}{
			"totalDistance": 0.0,
			"totalRuns":     0,
		}, nil
	}

	return results[0], nil
}

// models/run.go

// GetYearlyHistogram gets yearly histogram data for a user
func (m *RunModel) GetYearlyHistogram(userID string, startDate, endDate time.Time) ([]HistogramData, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	pipeline := []bson.M{
		{"$match": bson.M{
			"userId":    userID,
			"timestamp": bson.M{"$gte": startDate, "$lte": endDate},
		}},
		{"$group": bson.M{
			"_id": bson.M{
				"$dateTrunc": bson.M{
					"date": "$timestamp",
					"unit": "year",
				},
			},
			"totalDistance": bson.M{"$sum": "$distance"},
			"count":         bson.M{"$sum": 1},
		}},
		{"$sort": bson.M{"_id": 1}},
	}

	cursor, err := m.collection.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var results []HistogramData
	if err := cursor.All(ctx, &results); err != nil {
		return nil, err
	}
	return results, nil
}
