package helpers

import (
	"context"
	"errors"
	"fmt"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
	"go.mongodb.org/mongo-driver/v2/mongo/options"

	database "github.com/HarDizzeR/Project/backend/internal/database"
	logger "github.com/HarDizzeR/Project/backend/internal/logger"
)

// Token claims structures
type AccessClaims struct {
	UserID   string `json:"id"`
	UserType string `json:"userType"`
	jwt.RegisteredClaims
}

type RefreshClaims struct {
	UserID   string `json:"id"`
	UserType string `json:"userType"`
	jwt.RegisteredClaims
}

var (
	accessSecretKey    []byte
	refreshSecretKey   []byte
	accessTokenExpiry                    = 15 * time.Minute
	refreshTokenExpiry                   = 7 * 24 * time.Hour
	userCollection     *mongo.Collection = database.Users()
)

func InitSecurityConfig() error {

	if database.Client == nil {
		return errors.New("database client not initialized")
	}

	accessSecretKey = []byte(os.Getenv("ACCESS_SECRET_KEY"))
	refreshSecretKey = []byte(os.Getenv("REFRESH_SECRET_KEY"))

	if len(accessSecretKey) < 32 {
		return fmt.Errorf("ACCESS_SECRET_KEY must be at least 32 characters long")
	}
	if len(refreshSecretKey) < 32 && len(refreshSecretKey) > 0 {
		return fmt.Errorf("REFRESH_SECRET_KEY must be at least 32 characters long if set")
	}
	if len(refreshSecretKey) == 0 {
		refreshSecretKey = accessSecretKey
		logger.Warn("Using access secret for refresh tokens - recommend setting separate REFRESH_SECRET_KEY")
	}
	return nil
}

func GenerateAllTokens(userID, userType string) (accessToken, refreshToken string, err error) {
	// Generate access token
	accessClaims := AccessClaims{
		UserID:   userID,
		UserType: userType,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(accessTokenExpiry)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	accessToken, err = jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims).SignedString(accessSecretKey)
	if err != nil {
		logger.Errorf("Access token generation failed: %v", err)
		return "", "", fmt.Errorf("failed to generate access token: %w", err)
	}

	// Generate refresh token
	refreshClaims := RefreshClaims{
		UserID:   userID,
		UserType: userType,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(refreshTokenExpiry)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	refreshToken, err = jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims).SignedString(refreshSecretKey)
	if err != nil {
		logger.Errorf("Refresh token generation failed: %v", err)
		return "", "", fmt.Errorf("failed to generate refresh token: %w", err)
	}

	return accessToken, refreshToken, nil
}

func GenerateAccessToken(userID, userType string) (string, error) {
	accessClaims := AccessClaims{
		UserID:   userID,
		UserType: userType,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(accessTokenExpiry)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	accessToken, err := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims).SignedString(accessSecretKey)
	if err != nil {
		logger.Errorf("Access token generation failed: %v", err)
		return "", fmt.Errorf("failed to generate access token: %w", err)
	}

	return accessToken, nil
}

func GenerateRefreshToken(userID, userType string) (string, error) {
	refreshClaims := RefreshClaims{
		UserID:   userID,
		UserType: userType,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(refreshTokenExpiry)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	refreshToken, err := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims).SignedString(refreshSecretKey)
	if err != nil {
		logger.Errorf("Refresh token generation failed: %v", err)
		return "", fmt.Errorf("failed to generate refresh token: %w", err)
	}

	return refreshToken, nil
}

func UpdateAllTokens(ctx context.Context, accessToken, refreshToken, userID string) error {
	objID, err := bson.ObjectIDFromHex(userID)
	if err != nil {
		return fmt.Errorf("invalid user ID format: %w", err)
	}

	update := bson.D{
		{Key: "$set", Value: bson.D{
			{Key: "token", Value: accessToken},
			{Key: "refresh_token", Value: refreshToken},
			{Key: "updated_at", Value: time.Now()},
		}},
	}

	opts := options.UpdateOne().SetUpsert(false)
	_, err = userCollection.UpdateByID(ctx, objID, update, opts)
	if err != nil {
		logger.Errorf("Token update failed for user %s: %v", userID, err)
		return fmt.Errorf("failed to update tokens: %w", err)
	}

	return nil
}

func UpdateAccessToken(ctx context.Context, accessToken, userID string) error {
	objID, err := bson.ObjectIDFromHex(userID)
	if err != nil {
		return fmt.Errorf("invalid user ID format: %w", err)
	}

	update := bson.D{
		{Key: "$set", Value: bson.D{
			{Key: "token", Value: accessToken},
			{Key: "updated_at", Value: time.Now()},
		}},
	}

	opts := options.UpdateOne().SetUpsert(false)
	_, err = userCollection.UpdateByID(ctx, objID, update, opts)
	if err != nil {
		logger.Errorf("Access token update failed for user %s: %v", userID, err)
		return fmt.Errorf("failed to update access token: %w", err)
	}

	return nil
}

func ValidateAccessToken(tokenString string) (*AccessClaims, error) {
	token, err := jwt.ParseWithClaims(
		tokenString,
		&AccessClaims{},
		func(t *jwt.Token) (interface{}, error) {
			if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
			}
			return accessSecretKey, nil
		},
		jwt.WithLeeway(5*time.Second),
	)

	if err != nil {
		if errors.Is(err, jwt.ErrTokenExpired) {
			return nil, errors.New("token has expired")
		}
		return nil, fmt.Errorf("invalid token: %w", err)
	}

	claims, ok := token.Claims.(*AccessClaims)
	if !ok || !token.Valid {
		return nil, errors.New("invalid token claims")
	}

	return claims, nil
}

func ValidateRefreshToken(tokenString string) (*RefreshClaims, error) {
	token, err := jwt.ParseWithClaims(
		tokenString,
		&RefreshClaims{},
		func(t *jwt.Token) (interface{}, error) {
			if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
			}
			return refreshSecretKey, nil
		},
		jwt.WithLeeway(5*time.Second),
	)

	if err != nil {
		if errors.Is(err, jwt.ErrTokenExpired) {
			return nil, errors.New("refresh token has expired")
		}
		return nil, fmt.Errorf("invalid refresh token: %w", err)
	}

	claims, ok := token.Claims.(*RefreshClaims)
	if !ok || !token.Valid {
		return nil, errors.New("invalid refresh token claims")
	}

	return claims, nil
}
