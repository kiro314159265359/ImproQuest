package controllers

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"

	"github.com/HarDizzeR/Project/backend/internal/database"
	"github.com/HarDizzeR/Project/backend/internal/helpers"
	"github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/HarDizzeR/Project/backend/internal/models"

	"github.com/gorilla/sessions"
	"github.com/joho/godotenv"
	"github.com/markbates/goth"
	"github.com/markbates/goth/gothic"
	"github.com/markbates/goth/providers/google"
	"go.uber.org/zap"
)

var (
	userCollection *mongo.Collection = database.Users()
	validate       *validator.Validate
	store          *sessions.CookieStore
)

func init() {
	validate = validator.New()

}

// DTOs
type SignupRequest struct {
	Email        string   `json:"email" validate:"required,email"`
	MobileNumber *string  `bson:"mobile_number"`
	Username     *string  `bson:"username" validate:"required,min=2,max=200"`
	Password     string   `json:"password" validate:"required,min=8"`
	Height       *float64 `bson:"height" validate:"required,min=50,max=300"`
	Weight       *float64 `bson:"weight" validate:"required,min=30,max=300"`
	Gender       *string  `bson:"gender" validate:"required,oneof=Male Female"`
	BirthDate    string   `bson:"birth_date" validate:"required"` // Changed to string
	UserType     *string  `bson:"user_type" validate:"required,oneof=Admin User"`
}

type LoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

type UserResponse struct {
	ID        bson.ObjectID `json:"id"`
	Email     string        `json:"email"`
	Username  string        `json:"username"`
	UserType  string        `json:"user_type"`
	CreatedAt time.Time     `json:"created_at"`
}

func Signup() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 10*time.Second)
		defer cancel()

		var req SignupRequest
		if err := c.ShouldBindJSON(&req); err != nil {
			logger.Errorf("Invalid Request Format: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format", "message": err.Error()})
			return
		}

		// Parse the date string
		fmt.Println(req.BirthDate)
		birthDate, err := time.Parse("01/02/2006", req.BirthDate)
		fmt.Println(birthDate)
		if err != nil {
			logger.Errorf("Invalid date format: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid date format. Use MM/dd/yyyy"})
			return
		}

		if err := validate.Struct(req); err != nil {
			var validationErrors []string
			for _, err := range err.(validator.ValidationErrors) {
				validationErrors = append(validationErrors, fmt.Sprintf("%s: %s", err.Field(), err.Tag()))
			}
			logger.Errorf("Validation error: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"errors": validationErrors})
			return
		}

		if age := helpers.CalculateAge(birthDate); age < 13 {
			logger.Errorf("Invalid Age")
			c.JSON(http.StatusBadRequest, gin.H{"error": "User must be at least 13 years old"})
			return
		}

		count, err := userCollection.CountDocuments(ctx, bson.M{"email": req.Email})
		if err != nil {
			logger.Errorf("Email check error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Registration temporarily unavailable"})
			return
		}
		if count > 0 {
			c.JSON(http.StatusConflict, gin.H{"error": "Email already registered"})
			return
		}

		hashedPassword, err := helpers.HashPassword(req.Password)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
			return
		}

		user := models.User{
			Email:      &req.Email,
			Password:   &hashedPassword,
			Username:   req.Username,
			BirthDate:  birthDate, // Use the parsed date
			UserType:   req.UserType,
			Created_at: time.Now(),
			Updated_at: time.Now(),
			ID:         bson.NewObjectID(),
		}

		access, refresh, err := helpers.GenerateAllTokens(user.ID.Hex(), *user.UserType)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate tokens"})
			return
		}

		user.Token = &access
		user.Refresh_token = &refresh

		if _, err := userCollection.InsertOne(ctx, user); err != nil {
			logger.Errorf("User creation failed: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
			return
		}

		helpers.SetAuthCookies(c, access, refresh)
		c.JSON(http.StatusCreated, UserResponse{
			ID:        user.ID,
			Email:     *user.Email,
			Username:  *user.Username,
			UserType:  *user.UserType,
			CreatedAt: user.Created_at,
		})
	}
}

func Login() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 10*time.Second)
		defer cancel()

		var req LoginRequest
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
			return
		}

		var user models.User
		err := userCollection.FindOne(ctx, bson.M{"email": req.Email}).Decode(&user)
		if err != nil {
			logger.Warnf("Login attempt for unknown email: %s", req.Email)
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
			return
		}

		if err := helpers.VerifyPassword(req.Password, *user.Password); err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
			return
		}

		access, refresh, err := helpers.GenerateAllTokens(user.ID.Hex(), *user.UserType)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate tokens"})
			return
		}

		if err := helpers.UpdateAllTokens(ctx, access, refresh, user.ID.Hex()); err != nil {
			logger.Errorf("Token update failed: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Login failed"})
			return
		}

		helpers.SetAuthCookies(c, access, refresh)
		c.JSON(http.StatusOK, gin.H{
			"message": "Login successful",
			"user": UserResponse{
				ID:        user.ID,
				Email:     *user.Email,
				Username:  *user.Username,
				UserType:  *user.UserType,
				CreatedAt: user.Created_at,
			},
		})
	}
}

func InitAuthProviders() {

	err := godotenv.Load("config/.env")
	if err != nil {
		logger.Fatal("Error loading .env file: %v", zap.Error(err))
	}

	GOOGLE_CLIENT_ID := os.Getenv("GOOGLE_CLIENT_ID")
	GOOGLE_CLIENT_SECRET := os.Getenv("GOOGLE_CLIENT_SECRET")

	goth.UseProviders(
		google.New(GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, "http://localhost:5000/auth/google/callback"),
	)
}

func InitSessionStore() {

	err := godotenv.Load("config/.env")
	if err != nil {
		logger.Fatal("Error loading .env file: %v", zap.Error(err))
	}

	// !TODO : Change this to a more secure secret key

	SECRET_KEY := os.Getenv("SECRET_KEY")

	store = sessions.NewCookieStore([]byte(SECRET_KEY))
	gothic.Store = store
}

func BeginAuthHandler(c *gin.Context) {
	provider := c.Param("provider")

	// Set the provider in the context
	c.Request = c.Request.WithContext(context.WithValue(c.Request.Context(), gothic.ProviderParamKey, provider))

	// Check if user is already authenticated
	if _, err := gothic.CompleteUserAuth(c.Writer, c.Request); err == nil {
		c.JSON(200, gin.H{"message": "User is already authenticated"})
		return
	}

	gothic.BeginAuthHandler(c.Writer, c.Request)
}

func AuthCallbackHandler(c *gin.Context) {
	user, err := gothic.CompleteUserAuth(c.Writer, c.Request)
	if err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}
	c.JSON(200, gin.H{"user": user})
}

func Logout() gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.GetString("id")
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()

		if _, err := userCollection.UpdateByID(
			ctx,
			userID,
			bson.M{"$set": bson.M{"token": "", "refresh_token": ""}},
		); err != nil {
			logger.Warnf("Logout token clear failed: %v", err)
		}

		helpers.ClearAuthCookies(c)
		c.JSON(http.StatusOK, gin.H{"message": "Logged out successfully"})
	}
}
