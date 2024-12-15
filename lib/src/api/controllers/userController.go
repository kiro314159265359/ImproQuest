package controllers

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"golang.org/x/crypto/bcrypt"

	"kiro.com/database"
	helper "kiro.com/helpers"
	"kiro.com/models"
)

var userCollection *mongo.Collection = database.OpenCollection(database.Client, "user")
var validate = validator.New()

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
			c.JSON(http.StatusBadRequest, gin.H{"error": validationErr.Error()})
			return
		}

		count, err := userCollection.CountDocuments(ctx, bson.M{"email": user.Email})
		defer cancel()
		if err != nil {
			log.Panic(err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error while checking the Email"})
			return
		}

		if count > 0 {
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

		user.ID = primitive.NewObjectID()
		user.User_id = user.ID.Hex()

		Token, Refresh_token, _ := helper.GenrateAllTokens(*user.Email, *user.UserName, *user.UserType, user.User_id)
		user.Token = &Token
		user.Refresh_token = &Refresh_token

		resultInsertionNumber, insertErr := userCollection.InsertOne(ctx, user)
		if insertErr != nil {
			msg := fmt.Sprintf("User Wasn't Created")
			c.JSON(http.StatusInternalServerError, gin.H{"Error": msg})
			return
		}
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
		token, refreshToken, _ := helper.GenrateAllTokens(*foundUser.Email, *foundUser.UserName, *foundUser.UserType, foundUser.User_id)
		helper.UpdateAllTokins(token, refreshToken, foundUser.User_id)

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

		recPerPage, err := strconv.Atoi(c.Query("RecordPerPage"))
		if err != nil || recPerPage < 1 {
			recPerPage = 10
		}
		page, err1 := strconv.Atoi(c.Query("Page"))
		if err1 != nil || page < 1 {
			page = 1
		}

		startIndex := (page - 1) * recPerPage
		startIndex, err = strconv.Atoi(c.Query("startIndex"))

		matchStage := bson.D{{Key: "$match", Value: bson.D{{}}}}

		groupStage := bson.D{
			{Key: "$group", Value: bson.D{
				{Key: "_id", Value: "null"}, // Group all documents
				{Key: "total_count", Value: bson.D{
					{Key: "$sum", Value: 1}, // Count total documents
				}},
				{Key: "data", Value: bson.D{
					{Key: "$push", Value: "$$ROOT"}, // Push all document fields into the "data" array
				}},
			}},
		}

		projectStage := bson.D{
			{Key: "$project", Value: bson.D{
				{Key: "_id", Value: 0},         // Exclude `_id`
				{Key: "total_count", Value: 1}, // Include `total_count`
				{Key: "user_items", Value: bson.D{
					{Key: "$slice", Value: bson.A{"$data", startIndex, recPerPage}}, // Slice `data` array
				}},
			}},
		}

		cursor, err := userCollection.Aggregate(ctx, mongo.Pipeline{
			matchStage, groupStage, projectStage,
		})
		if err != nil {
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
		userID := c.Param("User_id")

		if err := helper.MatchUserToid(c, userID); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		var user models.User

		err := userCollection.FindOne(ctx, bson.M{"User_id": userID}).Decode(&user)

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, user)
	}

}
