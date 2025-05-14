// file: internal/utils/jwt.go
package utils

import (
    "errors"
    "os"
    "strings"
    "time"

    "github.com/gin-gonic/gin"
    "github.com/golang-jwt/jwt/v5"
    "go.mongodb.org/mongo-driver/v2/bson"
)

// tokenTTL defines how long the reset‑token JWT is valid.
const tokenTTL = 15 * time.Minute

// GenerateShortLivedJWT creates an HS256‑signed JWT whose subject is the hex of userID.
// Requires JWT_SECRET in your environment.
func GenerateShortLivedJWT(userID bson.ObjectID) (string, error) {
    secret := []byte(os.Getenv("JWT_SECRET"))
    if len(secret) == 0 {
        return "", errors.New("JWT_SECRET not set in environment")
    }

    claims := jwt.RegisteredClaims{
        Subject:   userID.Hex(),
        IssuedAt:  jwt.NewNumericDate(time.Now()),
        ExpiresAt: jwt.NewNumericDate(time.Now().Add(tokenTTL)),
    }
    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    return token.SignedString(secret)
}

// GetUserIDFromJWT validates the Bearer JWT in Gin’s Authorization header
// and returns the ObjectID stored in its subject.
func GetUserIDFromJWT(c *gin.Context) (bson.ObjectID, error) {
    auth := c.GetHeader("Authorization")
    if auth == "" {
        return bson.NilObjectID, errors.New("authorization header missing")
    }
    parts := strings.SplitN(auth, " ", 2)
    if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
        return bson.NilObjectID, errors.New("authorization header must be Bearer {token}")
    }
    tokenStr := parts[1]

    secret := []byte(os.Getenv("JWT_SECRET"))
    if len(secret) == 0 {
        return bson.NilObjectID, errors.New("JWT_SECRET not set in environment")
    }

    parsed, err := jwt.ParseWithClaims(tokenStr, &jwt.RegisteredClaims{}, func(tok *jwt.Token) (interface{}, error) {
        if tok.Method != jwt.SigningMethodHS256 {
            return nil, errors.New("unexpected signing method")
        }
        return secret, nil
    })
    if err != nil {
        return bson.NilObjectID, err
    }
    claims, ok := parsed.Claims.(*jwt.RegisteredClaims)
    if !ok || !parsed.Valid {
        return bson.NilObjectID, errors.New("invalid token")
    }

    // Directly use bson.ObjectIDFromHex (primitive merged into bson) :contentReference[oaicite:0]{index=0}:contentReference[oaicite:1]{index=1}
    return bson.ObjectIDFromHex(claims.Subject)
}
