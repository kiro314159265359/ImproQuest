package database

import (
	"context"
	"errors"
	"log"
	"time"

	"go.mongodb.org/mongo-driver/v2/mongo"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

func InitRunsCollection() {
	// 1. Create a context with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// 2. Configure time-series options
	tsOpts := options.TimeSeries().
		SetTimeField("timestamp").
		SetMetaField("userId").
		SetGranularity("seconds")

	// 3. Wrap in CreateCollectionOptions
	createOpts := options.CreateCollection().
		SetTimeSeriesOptions(tsOpts)

	// 4. Attempt to create the collection
	err := Client.Database("App").
		CreateCollection(ctx, "Runs", createOpts)
	if err != nil {
		// 5. Ignore already‑exists error, fail otherwise
		var cmdErr mongo.CommandError
		if errors.As(err, &cmdErr) && cmdErr.Code == 48 {
			return
		}
		log.Fatalf("failed to create Runs collection: %v", err)
	}
}
