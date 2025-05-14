package services

import (
	"context"
	"crypto/rand"
	"fmt"
	"time"

	"github.com/HarDizzeR/Project/backend/internal/database"
	"github.com/HarDizzeR/Project/backend/internal/models"
	"github.com/HarDizzeR/Project/backend/internal/utils"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
)

type PasswordResetService struct {
	userCol *mongo.Collection
}

func NewPasswordResetService() *PasswordResetService {
	return &PasswordResetService{userCol: database.Users()}
}

func (s *PasswordResetService) SendResetOTP(ctx context.Context, email string) error {
	// find user
	var u models.User
	if err := s.userCol.FindOne(ctx, bson.M{"email": email}).Decode(&u); err != nil {
		// don't reveal whether email exists
		return nil
	}
	// generate 6‑digit numeric OTP
	num := make([]byte, 3)
	if _, err := rand.Read(num); err != nil {
		return err
	}
	otp := fmt.Sprintf("%06d", int(num[0])<<16|int(num[1])<<8|int(num[2])%1000000)

	expires := time.Now().Add(10 * time.Minute)
	// store OTP + expiry
	_, err := s.userCol.UpdateOne(ctx,
		bson.M{"_id": u.ID},
		bson.M{"$set": bson.M{
			"password_reset_token":      otp,
			"password_reset_expires_at": expires,
			"updated_at":                time.Now(),
		}},
	)
	if err != nil {
		return err
	}
	// email OTP
	return utils.SendOTPEmail(email, otp)
}

func (s *PasswordResetService) VerifyOTP(ctx context.Context, email, otp string) (*models.User, error) {
	var u models.User
	filter := bson.M{
		"email":                     email,
		"password_reset_token":      otp,
		"password_reset_expires_at": bson.M{"$gt": time.Now()},
	}
	if err := s.userCol.FindOne(ctx, filter).Decode(&u); err != nil {
		return nil, err
	}
	return &u, nil
}

func (s *PasswordResetService) ResetPassword(ctx context.Context, userID bson.ObjectID, hashedPassword string) error {
	_, err := s.userCol.UpdateOne(ctx,
		bson.M{"_id": userID},
		bson.M{
			"$set": bson.M{"password": hashedPassword, "updated_at": time.Now()},
			"$unset": bson.M{
				"password_reset_token":      "",
				"password_reset_expires_at": "",
			},
		},
	)
	return err
}
