package models

import (
	"context"
	"errors"
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

// TodayDistance holds the total distance for today.
type TodayDistance struct {
	TotalDistance float64 `json:"totalDistance" bson:"totalDistance"`
}

// DailyDistanceData represents aggregated run data for a specific day, including the weekday.
type DailyDistanceData struct {
	Date     time.Time `json:"date" bson:"_id"`
	Weekday  string    `json:"weekday"`
	Distance float64   `json:"distance" bson:"totalDistance"`
	Count    int       `json:"count" bson:"count"`
}

// ErrNoDataFound is returned when a query yields no results for a specific period where data might be expected.
var ErrNoDataFound = errors.New("no data found for the specified period")

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

// GetTodayTotalDistance calculates the total distance run today by a user.
func (m *RunModel) GetTodayTotalDistance(userID string) (*TodayDistance, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	now := time.Now().In(time.UTC)
	startOfDay := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.UTC)
	endOfDay := startOfDay.AddDate(0, 0, 1)

	pipeline := []bson.M{
		{
			"$match": bson.M{
				"userId": userID,
				"timestamp": bson.M{
					"$gte": startOfDay,
					"$lt":  endOfDay,
				},
			},
		},
		{
			"$group": bson.M{
				"_id":           nil,
				"totalDistance": bson.M{"$sum": "$distance"},
			},
		},
		{
			"$project": bson.M{
				"_id":           0,
				"totalDistance": 1,
			},
		},
	}

	cursor, err := m.collection.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var results []TodayDistance
	if err = cursor.All(ctx, &results); err != nil {
		return nil, err
	}

	if len(results) == 0 {
		return nil, ErrNoDataFound
	}
	return &results[0], nil
}

// GetDailyDistancesForWeek gets the total distance for each day of the week containing targetDate.
func (m *RunModel) GetDailyDistancesForWeek(userID string, targetDate time.Time) ([]DailyDistanceData, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	targetDate = targetDate.In(time.UTC)
	// Calculate start of the week (Monday)
	offset := int(time.Monday - targetDate.Weekday())
	if targetDate.Weekday() == time.Sunday { // In Go, Sunday is 0, Monday is 1.
		offset = -6 // if today is Sunday, Monday was 6 days ago
	}
	startOfWeekDay := targetDate.AddDate(0, 0, offset)
	startOfWeek := time.Date(startOfWeekDay.Year(), startOfWeekDay.Month(), startOfWeekDay.Day(), 0, 0, 0, 0, time.UTC)
	endOfWeek := startOfWeek.AddDate(0, 0, 7) // Start of the next week

	pipeline := []bson.M{
		{
			"$match": bson.M{
				"userId": userID,
				"timestamp": bson.M{
					"$gte": startOfWeek,
					"$lt":  endOfWeek,
				},
			},
		},
		{
			"$group": bson.M{
				"_id": bson.M{
					"$dateTrunc": bson.M{
						"date":     "$timestamp",
						"unit":     "day",
						"timezone": "UTC",
					},
				},
				"totalDistance": bson.M{"$sum": "$distance"},
				"count":         bson.M{"$sum": 1},
			},
		},
		{"$sort": bson.M{"_id": 1}},
	}

	cursor, err := m.collection.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var rawResults []HistogramData // Use HistogramData for unmarshalling BSON
	if err = cursor.All(ctx, &rawResults); err != nil {
		return nil, err
	}

	if len(rawResults) == 0 {
		return nil, ErrNoDataFound
	}

	// Transform to DailyDistanceData to include Weekday
	results := make([]DailyDistanceData, len(rawResults))
	for i, r := range rawResults {
		results[i] = DailyDistanceData{
			Date:     r.Date, // r.Date is already in UTC due to $dateTrunc with timezone "UTC"
			Weekday:  r.Date.Weekday().String(),
			Distance: r.Distance,
			Count:    r.Count,
		}
	}
	return results, nil
}

// GetWeeklyDistancesForMonth gets the total distance for each week of the month containing targetDate.
// Weeks start on Monday.
func (m *RunModel) GetWeeklyDistancesForMonth(userID string, targetDate time.Time) ([]HistogramData, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	targetDate = targetDate.In(time.UTC)
	startOfMonth := time.Date(targetDate.Year(), targetDate.Month(), 1, 0, 0, 0, 0, time.UTC)
	endOfMonth := startOfMonth.AddDate(0, 1, 0) // Start of the next month

	pipeline := []bson.M{
		{
			"$match": bson.M{
				"userId": userID,
				"timestamp": bson.M{
					"$gte": startOfMonth,
					"$lt":  endOfMonth,
				},
			},
		},
		{
			"$group": bson.M{
				"_id": bson.M{
					"$dateTrunc": bson.M{
						"date":        "$timestamp",
						"unit":        "week",
						"timezone":    "UTC",
						"startOfWeek": "Monday",
					},
				},
				"totalDistance": bson.M{"$sum": "$distance"},
				"count":         bson.M{"$sum": 1},
			},
		},
		{"$sort": bson.M{"_id": 1}},
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

	if len(results) == 0 {
		return nil, ErrNoDataFound
	}
	return results, nil
}

// GetMonthlyDistancesForYear gets the total distance for each month of the specified year.
func (m *RunModel) GetMonthlyDistancesForYear(userID string, year int) ([]HistogramData, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	startOfYear := time.Date(year, time.January, 1, 0, 0, 0, 0, time.UTC)
	endOfYear := startOfYear.AddDate(1, 0, 0) // Start of the next year

	pipeline := []bson.M{
		{
			"$match": bson.M{
				"userId": userID,
				"timestamp": bson.M{
					"$gte": startOfYear,
					"$lt":  endOfYear,
				},
			},
		},
		{
			"$group": bson.M{
				"_id": bson.M{
					"$dateTrunc": bson.M{
						"date":     "$timestamp",
						"unit":     "month",
						"timezone": "UTC",
					},
				},
				"totalDistance": bson.M{"$sum": "$distance"},
				"count":         bson.M{"$sum": 1},
			},
		},
		{"$sort": bson.M{"_id": 1}},
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

	if len(results) == 0 {
		return nil, ErrNoDataFound
	}
	return results, nil
}
