package helpers

import (
	"errors"
	"net/http"

	jwt "github.com/dgrijalva/jwt-go"
	"github.com/gin-gonic/gin"
)

func DecodeJWT(tokenString string) (map[string]interface{}, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return []byte(SECRET_KEY), nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		return claims, nil
	}

	return nil, errors.New("invalid token")
}

func GetUserFromToken(ctx *gin.Context) string {
	tokenString := ctx.Request.Header.Get("token")
	claims, err := DecodeJWT(tokenString)
	if err != nil {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
		return ""
	}

	uid, ok := claims["Uid"].(string) // Extract `uid` from claims
	if !ok {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid token claims"})
		return ""
	}

	return uid
}
