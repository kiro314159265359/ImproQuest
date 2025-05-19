package models

import (
	"context"
	"time"

	"github.com/HarDizzeR/Project/backend/internal/database"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
)

type Streak struct {
	ID            bson.ObjectID `json:"_id,omitempty" bson:"_id,omitempty"`
	Current       int           `json:"current" bson:"current" validate:"gte=0"`
	HighestCount  int           `json:"highest_count" bson:"highest_count" validate:"gte=0"`
	LastCompleted time.Time     `bson:"last_completed" json:"last_completed" validate:"required"`
}

type UserEarnedAchievement struct {
	AchievementID bson.ObjectID `json:"achievement_id" bson:"achievement_id"`
	DateEarned    time.Time     `json:"date_earned" bson:"date_earned"`
}

type User struct {
	ID                     bson.ObjectID            `json:"_id,omitempty" bson:"_id,omitempty"`
	Username               *string                  `json:"username" bson:"username" validate:"required,min=2,max=200"`
	MobileNumber           *string                  `json:"mobile_number" bson:"mobile_number"`
	AvatarURL              *string                  `json:"avatar_url" bson:"avatar_url"`
	Email                  *string                  `json:"email" bson:"email" validate:"required,email"`
	Password               *string                  `json:"-" bson:"password" validate:"required,min=8"`
	Height                 *float64                 `json:"height" bson:"height" validate:"required,min=50,max=300"`
	Gender                 *string                  `json:"gender" bson:"gender" validate:"required,oneof=Male Female"`
	UserType               *string                  `json:"user_type" bson:"user_type" validate:"required,oneof=Admin User"`
	Token                  *string                  `json:"-" bson:"token,omitempty"`
	Refresh_token          *string                  `json:"-" bson:"refresh_token,omitempty"`
	BirthDate              time.Time                `json:"birth_date" bson:"birth_date" validate:"required"`
	Weight                 *float64                 `json:"weight" bson:"weight" validate:"required,min=30,max=300"`
	XP                     float64                  `json:"xp" bson:"xp" validate:"gte=0"`
	Level                  int                      `json:"level" bson:"level" validate:"gte=1"`
	Gold                   float64                  `json:"gold" bson:"gold" validate:"gte=0"`
	Streak                 Streak                   `json:"streak" bson:"streak" validate:"required"`
	InventoryID            bson.ObjectID            `json:"inventory_id" bson:"inventory_id" validate:"required"`       // Reference to Inventory
	UserAchievements       []UserEarnedAchievement  `json:"user_achievements" bson:"user_achievements" validate:"dive"` // Changed from Achievements []bson.ObjectID
	CurrentQuests          []Quest                  `json:"quests" bson:"quests" validate:"dive,required"`              // Embedded Quests
	Stats                  Stats                    `json:"stats" bson:"stats" validate:"required"`
	EquippedItems          map[string]bson.ObjectID `json:"equipped_items,omitempty" bson:"equipped_items,omitempty"`
	AccumDistance          float64                  `json:"accum_distance" bson:"accum_distance" validate:"gte=0"`
	Rank                   string                   `json:"rank" bson:"rank" validate:"required,oneof=E D C B A S"`
	SkillPoints            int                      `json:"skill_points" bson:"skill_points" validate:"gte=0"`
	CompletedQuestsCount   int                      `json:"completed_quests_count" bson:"completed_quests_count" validate:"gte=0"`
	PasswordResetToken     *string                  `json:"-" bson:"password_reset_token,omitempty"`
	PasswordResetExpiresAt *time.Time               `json:"-" bson:"password_reset_expires_at,omitempty"`
	Created_at             time.Time                `json:"created_at" bson:"Created_at" validate:"required"`
	Updated_at             time.Time                `json:"updated_at" bson:"Updated_at" validate:"required,gtefield=Created_at"`
}
type UserModel struct {
	Collection *mongo.Collection
}

func NewUserModel() *UserModel {
	return &UserModel{
		Collection: database.Users(),
	}
}
func (m *UserModel) FindByEmail(email string) (*User, error) {
	var user User
	// Look for the document where "email" matches
	err := m.Collection.
		FindOne(context.TODO(), bson.M{"email": email}).
		Decode(&user)
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (m *UserModel) SetPasswordResetToken(userID bson.ObjectID, token string, expiresAt time.Time) error {
	filter := bson.M{"_id": userID}
	update := bson.M{
		"$set": bson.M{
			"password_reset_token":      token,
			"password_reset_expires_at": expiresAt,
			"updated_at":                time.Now(),
		},
	}
	_, err := m.Collection.
		UpdateOne(context.TODO(), filter, update)
	return err
}
