package helpers

import (
	"time"

	"github.com/HarDizzeR/Project/backend/internal/models"
)

func AreAllQuestsCompleted(quests []models.Quest) bool {
	for _, quest := range quests {
		if !quest.IsCompleted {
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
