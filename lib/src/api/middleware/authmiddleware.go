package middleware

import (
	"net/http"

	helper "github.com/HarDizzeR/Project/helpers"
	"github.com/gin-gonic/gin"
)

func Authenticate() gin.HandlerFunc {
	return func(c *gin.Context) {
		clientToken, err := c.Cookie("session")

		if err != nil {
			c.JSON(http.StatusInternalServerError,
				gin.H{"error": err.Error()})
			c.Abort()
			return
		}

		if clientToken == "" {
			c.JSON(http.StatusInternalServerError,
				gin.H{"error": "No auth header provided"})
			c.Abort()
			return
		}

		claims, ok := helper.ValidateToken(clientToken)

		if ok != "" {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err})
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
