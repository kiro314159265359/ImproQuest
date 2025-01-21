package controllers

import (
	"context"
	"net/http"
	"time"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"

	"github.com/HarDizzeR/Project/backend/internal/database"
	helpers "github.com/HarDizzeR/Project/backend/internal/helpers"
	logger "github.com/HarDizzeR/Project/backend/internal/logger"
	"github.com/HarDizzeR/Project/backend/internal/models"

	"github.com/gorilla/sessions"
	"github.com/joho/godotenv"
	"github.com/markbates/goth"
	"github.com/markbates/goth/gothic"
	"github.com/markbates/goth/providers/google"
	"go.uber.org/zap"

	
)

var userCollection *mongo.Collection = database.OpenCollection(database.Client, "Users")
var validate = validator.New()
var store *sessions.CookieStore

func Signup() gin.HandlerFunc {

	return func(c *gin.Context) {
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		var user models.User

		if err := c.BindJSON(&user); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		validationErr := validate.Struct(user) //validation can be done in diff file
		if validationErr != nil {
			logger.Errorf("Validation error: %v", validationErr)
			c.JSON(http.StatusBadRequest, gin.H{"error": validationErr.Error()})
			return
		}

		count, err := userCollection.CountDocuments(ctx, bson.M{"email": user.Email})
		defer cancel()
		if err != nil {
			logger.Errorf("Error checking email existence: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error while checking the Email"})
			return
		}

		if count > 0 {
			logger.Warnf("Signup attempt with existing email: %s", *user.Email)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "this Email already exists"})
			return
		}

		currentYear := time.Now().Year()
		birthYear := user.BirthDate.Year()
		age := currentYear - birthYear
		if age < 13 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "User must be at least 13 years old"})
			return
		}

		hashedPassword, hashErr := helpers.HashPassword(*user.Password)
		if hashErr != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error while hashing the password"})
			return
		}
		user.Password = &hashedPassword

		user.Created_at = time.Now()
		user.Updated_at = time.Now()

		user.ID = bson.NewObjectID()

		Token, Refresh_token, _ := helpers.GenerateAllTokens(*user.Email, *user.UserName, *user.UserType, user.ID.Hex())
		user.Token = &Token
		user.Refresh_token = &Refresh_token

		_, insertErr := userCollection.InsertOne(ctx, user)
		if insertErr != nil {
			logger.Errorf("Failed to create user: %v", insertErr)
			msg := "User Wasn't Created"
			c.JSON(http.StatusInternalServerError, gin.H{"Error": msg})
			return
		}
		logger.Infof("New user created: %s", *user.Email)
		defer cancel()
		c.JSON(http.StatusOK, user)
	}
}

func Login() gin.HandlerFunc {
	return func(c *gin.Context) {
		var user models.User
		var foundUser models.User

		if err := c.BindJSON(&user); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		// Retrieve user from the database
		err := userCollection.FindOne(context.Background(), bson.M{"email": user.Email}).Decode(&foundUser)
		if err != nil {
			logger.Warnf("Login attempt failed for email: %s", *user.Email)
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
			return
		}

		// Compare the hashed password in the database with the provided password
		err = helpers.VerifyPassword(*user.Password, *foundUser.Password)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
			return
		}

		// Token generation and login success
		token, refreshToken, tokenErr := helpers.GenerateAllTokens(*foundUser.Email, *foundUser.UserName, *foundUser.UserType, foundUser.ID.Hex())
		if tokenErr != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate tokens"})
			return
		}

		c.SetCookie("session", token, 86400, "/", "localhost", false, true)

		logger.Infof("User logged in successfully: %s", *user.Email)
		c.JSON(http.StatusOK, gin.H{
			"message":       "Login successful",
			"token":         token,
			"refresh_token": refreshToken,
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
