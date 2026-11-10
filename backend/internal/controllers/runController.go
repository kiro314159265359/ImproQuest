package controllers

import (
	"errors"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"

	"github.com/HarDizzeR/Project/backend/internal/models"
)

// RunController handles HTTP requests related to runs
type RunController struct {
	runModel *models.RunModel
}

// NewRunController creates a new run controller
func NewRunController(runModel *models.RunModel) *RunController {
	return &RunController{
		runModel: runModel,
	}
}

// GetTodayTotalDistance handles requests for today's total run distance for a user.
func (c *RunController) GetTodayTotalDistance(ctx *gin.Context) {
	userID := ctx.Param("userId")
	if userID == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "userId is required"})
		return
	}

	distance, err := c.runModel.GetTodayTotalDistance(userID)
	if err != nil {
		if errors.Is(err, models.ErrNoDataFound) {
			ctx.JSON(http.StatusNotFound, gin.H{"error": models.ErrNoDataFound.Error()})
		} else {
			ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
		return
	}

	ctx.JSON(http.StatusOK, distance)
}

// GetDailyDistancesForWeek handles requests for daily run distances for a specific week.
// The week is determined by the 'date' query parameter (YYYY-MM-DD). Defaults to current week.
func (c *RunController) GetDailyDistancesForWeek(ctx *gin.Context) {
	userID := ctx.Param("userId")
	if userID == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "userId is required"})
		return
	}

	dateStr := ctx.DefaultQuery("date", "")
	targetDate := time.Now() // Default to today

	if dateStr != "" {
		parsedDate, err := time.Parse("2006-01-02", dateStr)
		if err != nil {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid date format. Use YYYY-MM-DD."})
			return
		}
		targetDate = parsedDate
	}

	distances, err := c.runModel.GetDailyDistancesForWeek(userID, targetDate)
	if err != nil {
		if errors.Is(err, models.ErrNoDataFound) {
			ctx.JSON(http.StatusNotFound, gin.H{"error": models.ErrNoDataFound.Error()})
		} else {
			ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
		return
	}

	ctx.JSON(http.StatusOK, distances)
}

// GetWeeklyDistancesForMonth handles requests for weekly run distances for a specific month.
// The month is determined by the 'date' query parameter (YYYY-MM-DD). Defaults to current month.
func (c *RunController) GetWeeklyDistancesForMonth(ctx *gin.Context) {
	userID := ctx.Param("userId")
	if userID == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "userId is required"})
		return
	}

	dateStr := ctx.DefaultQuery("date", "")
	targetDate := time.Now() // Default to today (current month)

	if dateStr != "" {
		parsedDate, err := time.Parse("2006-01-02", dateStr)
		if err != nil {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid date format. Use YYYY-MM-DD."})
			return
		}
		targetDate = parsedDate
	}

	distances, err := c.runModel.GetWeeklyDistancesForMonth(userID, targetDate)
	if err != nil {
		if errors.Is(err, models.ErrNoDataFound) {
			ctx.JSON(http.StatusNotFound, gin.H{"error": models.ErrNoDataFound.Error()})
		} else {
			ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
		return
	}

	ctx.JSON(http.StatusOK, distances)
}

// GetMonthlyDistancesForYear handles requests for monthly run distances for a specific year.
// The year is determined by the 'year' query parameter (YYYY). Defaults to current year.
func (c *RunController) GetMonthlyDistancesForYear(ctx *gin.Context) {
	userID := ctx.Param("userId")
	if userID == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "userId is required"})
		return
	}

	yearStr := ctx.DefaultQuery("year", "")
	targetYear := time.Now().Year() // Default to current year

	if yearStr != "" {
		parsedYear, err := strconv.Atoi(yearStr)
		if err != nil || parsedYear < 1900 || parsedYear > 2200 { // Basic validation
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid year format or value."})
			return
		}
		targetYear = parsedYear
	}

	distances, err := c.runModel.GetMonthlyDistancesForYear(userID, targetYear)
	if err != nil {
		if errors.Is(err, models.ErrNoDataFound) {
			ctx.JSON(http.StatusNotFound, gin.H{"error": models.ErrNoDataFound.Error()})
		} else {
			ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
		return
	}

	ctx.JSON(http.StatusOK, distances)
}
