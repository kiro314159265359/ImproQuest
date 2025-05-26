package helpers

import (
	"fmt"
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

func GenerateSunToSatWeeklyDisplay(dailyCompletions map[string]bool, today time.Time) [7]any {
	display := [7]any{}
	normalizedToday := today.Truncate(24 * time.Hour)

	// Find Sunday of the current week
	// today.Weekday() gives time.Sunday, time.Monday, ...
	daysSinceSunday := int(normalizedToday.Weekday() - time.Sunday) // Sunday is 0, Monday is 1, etc.
	if daysSinceSunday < 0 {                                        // Should not happen with Go's time.Weekday if Sunday is 0
		daysSinceSunday += 7
	}
	currentSunday := normalizedToday.AddDate(0, 0, -daysSinceSunday)

	for i := range 7 {
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

// CheckAndResetStreakForMissedDays checks if the user missed any days and resets streak accordingly
func CheckAndResetStreakForMissedDays(user *models.User) bool {
	if user.DailyCompletions == nil {
		user.DailyCompletions = make(map[string]bool)
	}

	currentTime := time.Now()
	today := currentTime.Truncate(24 * time.Hour)

	// If streak is already 0 or user never completed anything, no need to reset
	if user.Streak.Current == 0 || user.Streak.LastCompleted.IsZero() {
		return false
	}

	// Check if the last completed day is yesterday or today
	yesterday := today.AddDate(0, 0, -1)

	// If last completion was today, streak is still valid
	if SameDay(user.Streak.LastCompleted, today) {
		return false
	}

	// If last completion was yesterday, check if yesterday was actually completed
	if SameDay(user.Streak.LastCompleted, yesterday) {
		yesterdayKey := yesterday.Format("2006-01-02")
		if completed, found := user.DailyCompletions[yesterdayKey]; found && completed {
			// Yesterday was completed, streak is still valid
			return false
		}
	}

	// If we get here, the user missed at least one day - reset streak to 0
	// Debug log to confirm this is being called
	fmt.Printf("DEBUG: Resetting streak from %d to 0 for missed days\n", user.Streak.Current)
	user.Streak.Current = 0 // This DOES modify the original user struct because we received a pointer
	// Keep LastCompleted as is for reference, but the current streak is broken

	return true // Indicates that streak was reset
}
