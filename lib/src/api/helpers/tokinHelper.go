package helpers

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	jwt "github.com/dgrijalva/jwt-go"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"

	"github.com/HarDizzeR/Project/database"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
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

func GenrateAllTokens(email string, username string, UserType string, uid string) (signedTokens string, signedRefreshTokens string, err error) {
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

	Refresh_token, err := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims).SignedString([]byte(SECRET_KEY))

	if err != nil {
		log.Panic(err)
		return
	}

	return token, Refresh_token, err

}

func UpdateAllTokins(signedToken string, signedRefreshToken string, userID string) {
	var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
	defer cancel()

	UpdateObj := bson.D{
		{Key: "token", Value: signedToken},
		{Key: "refresh_token", Value: signedRefreshToken},
		{Key: "updated_at", Value: time.Now()},
	}

	upsert := true

	id, err := primitive.ObjectIDFromHex(userID)
	if err != nil {
		log.Panic(err)
		return
	}

	filter := bson.M{"_id": id}

	opt := options.UpdateOptions{
		Upsert: &upsert,
	}

	_, err = userCollection.UpdateOne(
		ctx,
		filter,
		bson.D{
			{Key: "$set", Value: UpdateObj},
		},
		&opt,
	)

	if err != nil {
		log.Panic(err)
		return
	}

}

func ValidateToken(SignedToken string) (Claims *SignedDetails, msg string) {
	token, err := jwt.ParseWithClaims(
		SignedToken,
		&SignedDetails{},
		func(token *jwt.Token) (interface{}, error) {
			return []byte(SECRET_KEY), nil
		},
	)

	if err != nil {
		msg = err.Error()
		return
	}

	claims, ok := token.Claims.(*SignedDetails)

	if !ok {
		msg += fmt.Sprintf("Token is invalid")
		msg = err.Error()
		return
	}

	if claims.ExpiresAt < time.Now().Local().Unix() {
		msg += fmt.Sprintf("Token is expierd")
		msg = err.Error()
		return
	}

	return claims, msg
}
