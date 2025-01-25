package middleware

import (
	"net/http"

	"github.com/HarDizzeR/Project/backend/internal/helpers"
	"github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/gin-gonic/gin"
)

func Authenticate() gin.HandlerFunc {
	return func(c *gin.Context) {
		clientToken, err := c.Cookie("access_token")

		if err != nil {
			logger.Errorf("Session cookie not found")
			c.JSON(http.StatusInternalServerError, gin.H{"name": "Session cookie not found", "error": err.Error()})
			c.Abort()
			return
		}

		if clientToken == "" {
			logger.Warnf("No auth header provided")
			c.JSON(http.StatusInternalServerError,
				gin.H{"error": "No auth header provided"})
			c.Abort()
			return
		}

		claims, err := helpers.ValidateAccessToken(clientToken)
		if err != nil {
			logger.Errorf("Token validation error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			c.Abort()
			return
		}

		c.Set("id", claims.ID)
		c.Set("userType", claims.UserType)
		c.Next()
	}
}
