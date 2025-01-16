package helpers

import (
	"context"
	"fmt"
	"os"
	"time"

	jwt "github.com/golang-jwt/jwt"
	"go.mongodb.org/mongo-driver/v2/bson"

	"github.com/HarDizzeR/Project/database"
	logger "github.com/HarDizzeR/Project/logger"
	"go.mongodb.org/mongo-driver/v2/mongo"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
)

type SignedDetails struct {
	Email    string
	UserName string
	Uid      string
	UserType string
	jwt.StandardClaims
}

var userCollection *mongo.Collection = database.OpenCollection(database.Client, "Users")

var SECRET_KEY string = os.Getenv("SECRET_KEY")

func GenerateAllTokens(email string, username string, UserType string, uid string) (signedTokens string, signedRefreshTokens string, err error) {
	claims := &SignedDetails{
		Email:    email,
		UserName: username,
		UserType: UserType,
		Uid:      uid,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: time.Now().Local().Add(time.Hour * time.Duration(24)).Unix(),
		},
	}

	refreshClaims := &SignedDetails{
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: time.Now().Local().Add(time.Hour * time.Duration(168)).Unix(),
		},
	}

	token, err := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString([]byte(SECRET_KEY))
	if err != nil {
		logger.Errorf("Failed to generate token: %v", err)
		return "", "", err
	}

	Refresh_token, err := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims).SignedString([]byte(SECRET_KEY))
	if err != nil {
		logger.Errorf("Failed to generate refresh token: %v", err)
		return "", "", err
	}

	return token, Refresh_token, err

}

func UpdateAllTokens(signedToken string, signedRefreshToken string, userID string) error {
	var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
	defer cancel()

	UpdateObj := bson.D{
		{Key: "token", Value: signedToken},
		{Key: "refresh_token", Value: signedRefreshToken},
		{Key: "updated_at", Value: time.Now()},
	}

	upsert := true

	id, err := bson.ObjectIDFromHex(userID)
	if err != nil {
		return err
	}

	filter := bson.M{"_id": id}

	_, err = userCollection.UpdateOne(
		ctx,
		filter,
		bson.D{
			{Key: "$set", Value: UpdateObj},
		},
		options.UpdateOne().SetUpsert(upsert),
	)

	if err != nil {
		logger.Errorf("Failed to update tokens in DB: %v", err)
		return err
	}

	return nil
}

func ValidateToken(SignedToken string) (*SignedDetails, error) {
	token, err := jwt.ParseWithClaims(
		SignedToken,
		&SignedDetails{},
		func(token *jwt.Token) (interface{}, error) {
			return []byte(SECRET_KEY), nil
		},
	)

	if err != nil {
		logger.Errorf("Failed to parse token: %v", err)
		return nil, err
	}

	claims, ok := token.Claims.(*SignedDetails)

	if !ok || claims.ExpiresAt < time.Now().Local().Unix() {
		logger.Warnf("Invalid or expired token")
		return nil, fmt.Errorf("invalid or expired token")
	}

	return claims, nil
}
