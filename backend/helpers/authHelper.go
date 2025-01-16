package helpers

import (
	"errors"
	"fmt"

	"github.com/gin-gonic/gin"
	logger "github.com/HarDizzeR/Project/logger"
)

func CheckUserType(c *gin.Context, role string) (err error) {

	userType := c.GetString("userType")

	err = nil
	if userType != role {
		logger.Warnf("Unauthorized access attempt: required=%s, got=%s", role, userType)
		err := errors.New("unauthorized to access")
		return err
	}
	return err
}

func MatchUserToid(c *gin.Context, userID string) (err error) {

	userType := c.GetString("userType")
	uid := c.GetString("uid")
	err = nil

	if userType == "USER" && uid != userID {
		logger.Warnf("Unauthorized user ID match: uid=%s, param=%s", uid, userID)
		err = fmt.Errorf("unauthorized to access: userType = %s", userType)
		return err
	}

	err = CheckUserType(c, userType)
	return err
}
