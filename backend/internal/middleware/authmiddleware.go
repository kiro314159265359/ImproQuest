package middleware

import (
	// "fmt"
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
			c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error(), "message": " TOKEN_EXPIRED "})
			c.Abort()
			return
		}

		c.Set("id", claims.UserID)
		c.Set("userType", claims.UserType)
		c.Next()
	}
}

func CheckUserType(requiredRole string) gin.HandlerFunc {
	return func(c *gin.Context) {
		userType := c.GetString("userType")
		if userType != requiredRole {
			logger.Warnf("Unauthorized access attempt: required=%s, got=%s", requiredRole, userType)
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "unauthorized to access", "message": "User does not have permission to access this resource"})
			return
		}
		c.Next()
	}
}

// func MatchUserToId(expectedUserID string) gin.HandlerFunc {
// 	return func(c *gin.Context) {
// 		userType := c.GetString("userType")
// 		uid := c.GetString("id")
// 		// If the user is a normal user and their id does not match the expected one, abort.
// 		if userType == "User" && uid != expectedUserID {
// 			logger.Warnf("Unauthorized user ID match: uid=%s, expected=%s", uid, expectedUserID)
// 			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": fmt.Sprintf("unauthorized to access: userType = %s", userType), "message": "User does not have permission to access this resource"})
// 			return
// 		}
// 		c.Next()
// 	}
// }
