package helpers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/mongo"
)

func XpThresholdForLevel(level int) float64 {
	return float64(level * 100)
}

func HandleError(c *gin.Context, err error) bool {
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
		return true
	}
	return false
}

func GetRankForLevel(level int) string {
	switch {
	case level < 20:
		return "E"
	case level < 40:
		return "D"
	case level < 60:
		return "C"
	case level < 80:
		return "B"
	case level < 100:
		return "A"
	default:
		return "S"
	}
}
