package middleware

import (
	"net/http"
	"strings"

	"github.com/HarDizzeR/Project/backend/internal/helpers"
	"github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/gin-gonic/gin"
)

func Authenticate() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			logger.Warnf("No Authorization header provided")
			c.JSON(http.StatusUnauthorized, gin.H{"error": "No authorization header"})
			c.Abort()
			return
		}
		bearerSchema := "Bearer "
		tokenString := strings.TrimPrefix(authHeader, bearerSchema)
		if tokenString == authHeader {
			logger.Warnf("Invalid authorization format")
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid authorization format"})
			c.Abort()
			return
		}

		claims, err := helpers.ValidateAccessToken(tokenString)
		if err != nil {
			logger.Errorf("Token validation error: %v", err)
			c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
			c.Abort()
			return
		}

		c.Set("id", claims.UserID)
		c.Set("userType", claims.UserType)
		c.Next()
	}
}
