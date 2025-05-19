package services

import (
	"context"
	"time"

	"github.com/HarDizzeR/Project/backend/internal/database"
	"github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/HarDizzeR/Project/backend/internal/models"
	"go.mongodb.org/mongo-driver/v2/bson"
)

// AwardAchievements checks and awards any new achievements for the given user.
func AwardAchievements(ctx context.Context, userID bson.ObjectID) {
	userColl := database.Users()
	achColl := database.Achievements()

	var user models.User
	if err := userColl.FindOne(ctx, bson.M{"_id": userID}).Decode(&user); err != nil {
		logger.Errorf("AwardAchievements: fetch user %s: %v", userID.Hex(), err)
		return
	}

	cursor, err := achColl.Find(ctx, bson.M{})
	if err != nil {
		logger.Errorf("AwardAchievements: fetch achievements: %v", err)
		return
	}
	defer cursor.Close(ctx)

	var all []models.Achievement
	if err := cursor.All(ctx, &all); err != nil {
		logger.Errorf("AwardAchievements: decode achievements: %v", err)
		return
	}

	earned := make(map[bson.ObjectID]struct{})
	for _, ua := range user.UserAchievements {
		earned[ua.AchievementID] = struct{}{}
	}

	var toAdd []models.UserEarnedAchievement
	var names []string

	for _, a := range all {
		if _, ok := earned[a.ID]; ok {
			continue
		}
		var earnedNow bool
		switch a.TriggerType {
		case "DISTANCE":
			earnedNow = user.AccumDistance >= a.TriggerValue
		case "LEVEL":
			earnedNow = user.Level >= int(a.TriggerValue)
		case "STREAK":
			earnedNow = user.Streak.Current >= int(a.TriggerValue)
		case "QUESTS_COMPLETED":
			earnedNow = user.CompletedQuestsCount >= int(a.TriggerValue)
		}
		if earnedNow {
			toAdd = append(toAdd, models.UserEarnedAchievement{
				AchievementID: a.ID,
				DateEarned:    time.Now(),
			})
			names = append(names, a.Name)
			earned[a.ID] = struct{}{}
		}
	}

	if len(toAdd) == 0 {
		return
	}

	upd := bson.M{
		"$push": bson.M{"userachievements": bson.M{"$each": toAdd}},
		"$set":  bson.M{"updated_at": time.Now()},
	}
	if _, err := userColl.UpdateOne(ctx, bson.M{"_id": userID}, upd); err != nil {
		logger.Errorf("AwardAchievements: update user %s: %v", userID.Hex(), err)
	} else {
		logger.Infof("User %s awarded: %v", userID.Hex(), names)
	}
}
