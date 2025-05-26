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
