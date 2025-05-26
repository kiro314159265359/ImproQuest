package helpers

import (
	"time"

	"github.com/HarDizzeR/Project/backend/internal/models"
)

func AreAllQuestsCompleted(quests []models.Quest) bool {
	// Only check Running quests for streak completion
	// Custom quests (Mental/Habit) reset daily and shouldn't affect streaks
	for _, quest := range quests {
		if quest.Type != nil && *quest.Type == "Running" && !quest.IsCompleted {
			return false
		}
	}
	return true
}

func SameDay(a, b time.Time) bool {
	ay, am, ad := a.Date()
	by, bm, bd := b.Date()
	return ay == by && am == bm && ad == bd
}

func GenerateSunToSatWeeklyDisplay(dailyCompletions map[string]bool, today time.Time) [7]interface{} {
	display := [7]interface{}{}
	normalizedToday := today.Truncate(24 * time.Hour)

	// Find Sunday of the current week
	// today.Weekday() gives time.Sunday, time.Monday, ...
	daysSinceSunday := int(normalizedToday.Weekday() - time.Sunday) // Sunday is 0, Monday is 1, etc.
	if daysSinceSunday < 0 {                                        // Should not happen with Go's time.Weekday if Sunday is 0
		daysSinceSunday += 7
	}
	currentSunday := normalizedToday.AddDate(0, 0, -daysSinceSunday)

	for i := 0; i < 7; i++ {
		dayInWeek := currentSunday.AddDate(0, 0, i)
		dayKey := dayInWeek.Format("2006-01-02") // "YYYY-MM-DD"

		if dayInWeek.After(normalizedToday) {
			display[i] = nil // Future day
		} else {
			// Today or a past day
			if completed, found := dailyCompletions[dayKey]; found && completed {
				display[i] = true
			} else {
				display[i] = false // Not completed or not found in map (implies not completed)
			}
		}
	}
	return display
}
