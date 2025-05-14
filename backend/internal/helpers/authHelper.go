package helpers

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"

	"github.com/HarDizzeR/Project/backend/internal/logger"
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
	uid := c.GetString("id")
	err = nil

	if userType == "User" && uid != userID {
		logger.Warnf("Unauthorized user ID match: uid=%s, param=%s", uid, userID)
		err = fmt.Errorf("unauthorized to access: userType = %s", userType)
		return err
	}

	err = CheckUserType(c, userType)
	return err
}

func HashPassword(password string) (string, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(hashedPassword), nil
}

func VerifyPassword(password, hashedPassword string) error {

	err := bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(password))
	if err != nil {
		return fmt.Errorf("incorrect password")
	}
	return nil
}

func ClearAuthCookies(c *gin.Context) {
	c.SetCookie("access_token", "", -1, "/", "", false, true)
	c.SetCookie("refresh_token", "", -1, "/", "", false, true)
}

func CalculateAge(birthDate time.Time) int {
	now := time.Now()
	age := now.Year() - birthDate.Year()
	if now.Month() < birthDate.Month() || (now.Month() == birthDate.Month() && now.Day() < birthDate.Day()) {
		age--
	}
	return age
}

func SetAuthCookies(c *gin.Context, access, refresh string) {
	secure := os.Getenv("ENV") == "production"
	c.SetCookie("access_token", access, 86400, "/", "", secure, true)
	c.SetCookie("refresh_token", refresh, 86400*7, "/", "", secure, true)
}

func CheckPasswordHash(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

func GenerateSecureToken(length int) (string, error) {
	bytes := make([]byte, length) // Number of bytes, not string length after hex encoding
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	return hex.EncodeToString(bytes), nil // Hex encoding doubles the length
}
