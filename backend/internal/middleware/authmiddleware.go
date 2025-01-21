package middleware

import (
	"net/http"

	helpers "github.com/HarDizzeR/Project/backend/internal/helpers"
	logger "github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/gin-gonic/gin"
)

func Authenticate() gin.HandlerFunc {
	return func(c *gin.Context) {
		clientToken, err := c.Cookie("session")

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

		claims, validateErr := helpers.ValidateToken(clientToken)
		if validateErr != nil {
			logger.Errorf("Token validation error: %v", validateErr)
			c.JSON(http.StatusInternalServerError, gin.H{"error": validateErr.Error()})
			c.Abort()
			return
		}

		c.Set("email", claims.Email)
		c.Set("username", claims.UserName)
		c.Set("uid", claims.Uid)
		c.Set("userType", claims.UserType)
		c.Next()
	}
}
