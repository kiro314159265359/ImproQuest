package helpers

import (
	"errors"
	"fmt"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	
	logger "github.com/HarDizzeR/Project/backend/internal/logger"
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

func HashPassword(password string) (string, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if (err != nil) {
		return "", err
	}
	return string(hashedPassword), nil
}

func VerifyPassword(password, hashedPassword string) error {

	err := bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(password))
	if err != nil {
		fmt.Println("Stored Hashed Password: ", hashedPassword)
		fmt.Println("Plain Password: ", password)

		return fmt.Errorf("incorrect password")
	}
	return nil
}

