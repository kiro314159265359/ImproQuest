package helpers

import (
	"fmt"
	"time"
)

func ParseFlexibleDate(dateStr string) (time.Time, error) {
	// List of supported date formats
	formats := []string{
		time.RFC3339,               // "2018-01-12T00:00:00Z"
		"2006-01-02T15:04:05.000Z", // "2018-01-12T00:00:00.000Z"
		"2006-01-02T15:04:05.000",  // "2018-01-12T00:00:00.000" (your desired format)
		"2006-01-02T15:04:05",      // "2018-01-12T00:00:00"
		"2006-01-02",               // "2018-01-12"
		time.RFC3339Nano,           // with nanoseconds
	}

	for _, format := range formats {
		if t, err := time.Parse(format, dateStr); err == nil {
			return t, nil
		}
	}

	return time.Time{}, fmt.Errorf("unable to parse date: %s", dateStr)
}
