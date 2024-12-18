package helpers

import (
	"errors"
	"fmt"

	"github.com/gin-gonic/gin"
)

func CheckUserType(c *gin.Context, role string) (err error) {

	userType := c.GetString("userType")

	err = nil
	if userType != role {
		err := errors.New("unathorized to access")
		return err
	}
	return err
}

func MatchUserToid(c *gin.Context, userID string) (err error) {

	userType := c.GetString("userType")
	uid := c.GetString("uid")
	err = nil

	if userType == "USER" && uid != userID {
		err = fmt.Errorf("unauthorized to access: userType = %s", userType)
		return err
	}

	err = CheckUserType(c, userType)
	return err
}
