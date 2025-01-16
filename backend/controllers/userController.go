package controllers

import (
	"context"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
	"golang.org/x/crypto/bcrypt"

	"github.com/HarDizzeR/Project/database"
	helper "github.com/HarDizzeR/Project/helpers"
	"github.com/HarDizzeR/Project/models"
	logger "github.com/HarDizzeR/Project/logger"
)

var userCollection *mongo.Collection = database.OpenCollection(database.Client, "Users")
var validate = validator.New()

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

		hashedPassword, hashErr := HashPassword(*user.Password)
		if hashErr != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error while hashing the password"})
			return
		}
		user.Password = &hashedPassword

		user.Created_at = time.Now()
		user.Updated_at = time.Now()

		user.ID = bson.NewObjectID()

		Token, Refresh_token, _ := helper.GenerateAllTokens(*user.Email, *user.UserName, *user.UserType, user.ID.Hex())
		user.Token = &Token
		user.Refresh_token = &Refresh_token

		resultInsertionNumber, insertErr := userCollection.InsertOne(ctx, user)
		if insertErr != nil {
			logger.Errorf("Failed to create user: %v", insertErr)
			msg := "User Wasn't Created"
			c.JSON(http.StatusInternalServerError, gin.H{"Error": msg})
			return
		}
		logger.Infof("New user created: %s", *user.Email)
		defer cancel()
		c.JSON(http.StatusOK, resultInsertionNumber)
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
		err = VerifyPassword(*user.Password, *foundUser.Password)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
			return
		}

		// Token generation and login success
		token, refreshToken, tokenErr := helper.GenerateAllTokens(*foundUser.Email, *foundUser.UserName, *foundUser.UserType, foundUser.ID.Hex())
        if tokenErr != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate tokens"})
            return
        }
        helper.UpdateAllTokens(token, refreshToken, foundUser.ID.Hex())

		c.SetCookie("session", token, 86400, "/", "localhost", false, true)

		logger.Infof("User logged in successfully: %s", *user.Email)
		c.JSON(http.StatusOK, gin.H{
			"message":       "Login successful",
			"token":         token,
			"refresh_token": refreshToken,
		})
	}
}

func GetUsers() gin.HandlerFunc {
	return func(c *gin.Context) {
		err := helper.CheckUserType(c, "ADMIN")
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		ctx, cancel := context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		// Parse and validate pagination parameters
		recPerPage := 10 // Default value
		if limit := c.Query("RecordPerPage"); limit != "" {
			if val, err := strconv.Atoi(limit); err == nil && val > 0 && val <= 100 {
			recPerPage = val
			}
		}

		page := 1 // Default value
		if pageStr := c.Query("Page"); pageStr != "" {
			if val, err := strconv.Atoi(pageStr); err == nil && val > 0 {
			page = val
			}
		}

		startIndex := (page - 1) * recPerPage

		// Use more efficient aggregation pipeline
		matchStage := bson.D{{Key: "$match", Value: bson.D{}}}

		facetStage := bson.D{{Key: "$facet", Value: bson.D{
			{Key: "metadata", Value: bson.A{
			bson.D{{Key: "$count", Value: "total"}},
			}},
			{Key: "data", Value: bson.A{
			bson.D{{Key: "$skip", Value: startIndex}},
			bson.D{{Key: "$limit", Value: recPerPage}},
			}},
		}}}

		projectStage := bson.D{{Key: "$project", Value: bson.D{
			{Key: "length", Value: bson.D{{Key: "$arrayElemAt", Value: bson.A{"$metadata.total", 0}}}},
			{Key: "users", Value: "$data"},
		}}}

		cursor, err := userCollection.Aggregate(ctx, mongo.Pipeline{
			matchStage, facetStage, projectStage,
		})
		if err != nil {
			logger.Errorf("Failed to list users: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error while listing users"})
			return
		}
		defer cursor.Close(ctx)

		var results []bson.M
		if err := cursor.All(ctx, &results); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error while decoding results"})
			return
		}
		if len(results) > 0 {
			c.JSON(http.StatusOK, results[0])
		} else {
			c.JSON(http.StatusOK, gin.H{"total_count": 0, "user_items": []bson.M{}})
		}
	}

}

func GetUser() gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.Param("id")

		if err := helper.MatchUserToid(c, userID); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		var user models.User

		id, err := bson.ObjectIDFromHex(userID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid User ID"})
			return
		}

		err = userCollection.FindOne(ctx, bson.M{"_id": id}).Decode(&user)

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, user)
	}

}

func DeleteUser() gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.Param("id")

		if err := helper.MatchUserToid(c, userID); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
			return
		}
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		var user models.User

		id, err := bson.ObjectIDFromHex(userID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid format"})
			return
		}

		err = userCollection.FindOneAndDelete(ctx, bson.M{"_id": id}).Decode(&user)

		if err != nil {
			logger.Errorf("Failed to delete user %s: %v", userID, err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		logger.Infof("User deleted successfully: %s", userID)
		c.JSON(http.StatusOK, gin.H{"message": "User was deleted successfully", "user": user})
	}

}

func UpdateUser() gin.HandlerFunc {
	return func(c *gin.Context) {
		userID := c.Param("id")

		if err := helper.MatchUserToid(c, userID); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
			return
		}

		var userUpdateData models.User
		if err := c.BindJSON(&userUpdateData); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input"})
			return
		}

		updateFields := bson.M{}

		if userUpdateData.UserName != nil && *userUpdateData.UserName != "" {
			updateFields["username"] = *userUpdateData.UserName
		}
		if userUpdateData.Email != nil && *userUpdateData.Email != "" {
			updateFields["email"] = *userUpdateData.Email
		}
		if userUpdateData.Height != nil {
			updateFields["height"] = *userUpdateData.Height
		}
		if userUpdateData.Weight != nil {
			updateFields["weight"] = *userUpdateData.Weight
		}
		if userUpdateData.Gender != nil {
			updateFields["gender"] = *userUpdateData.Gender
		}

		if userUpdateData.Password != nil && *userUpdateData.Password != "" {
			hashedPassword, err := HashPassword(*userUpdateData.Password)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Couldn't hash password"})
				return
			}
			updateFields["password"] = hashedPassword
		}

		if len(updateFields) == 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "No data provided"})
			return
		}

		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		id, err := bson.ObjectIDFromHex(userID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid format"})
			return
		}
		update := bson.M{"$set": updateFields}

		result, err := userCollection.UpdateOne(ctx, bson.M{"_id": id}, update)
		if err != nil {
			logger.Errorf("Failed to update user %s: %v", userID, err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user"})
			return
		}

		if result.MatchedCount == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
			return
		}

		logger.Infof("User updated successfully: %s", userID)
		c.JSON(http.StatusOK, gin.H{"message": "User updated successfully"})
	}
}
