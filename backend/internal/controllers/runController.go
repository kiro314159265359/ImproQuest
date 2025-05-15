package controllers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"

	"github.com/HarDizzeR/Project/backend/internal/models" // Replace with your actual import path
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


// GetDailyHistogram handles requests for daily histogram data
func (c *RunController) GetDailyHistogram(ctx *gin.Context) {
	userID := ctx.Param("userId")
	if userID == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "userId is required"})
		return
	}

	// Parse date range parameters
	startDateStr := ctx.DefaultQuery("startDate", "")
	endDateStr := ctx.DefaultQuery("endDate", "")

	startDate := time.Now().AddDate(0, 0, -30) // Default to last 30 days
	endDate := time.Now()

	if startDateStr != "" {
		parsedStartDate, err := time.Parse("2006-01-02", startDateStr)
		if err == nil {
			startDate = parsedStartDate
		}
	}

	if endDateStr != "" {
		parsedEndDate, err := time.Parse("2006-01-02", endDateStr)
		if err == nil {
			endDate = parsedEndDate.AddDate(0, 0, 1) // Include the end date
		}
	}

	histogram, err := c.runModel.GetDailyHistogram(userID, startDate, endDate)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, histogram)
}

// GetWeeklyHistogram handles requests for weekly histogram data
func (c *RunController) GetWeeklyHistogram(ctx *gin.Context) {
	userID := ctx.Param("userId")
	if userID == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "userId is required"})
		return
	}

	// Parse date range parameters
	startDateStr := ctx.DefaultQuery("startDate", "")
	endDateStr := ctx.DefaultQuery("endDate", "")

	startDate := time.Now().AddDate(0, -3, 0) // Default to last 3 months
	endDate := time.Now()

	if startDateStr != "" {
		parsedStartDate, err := time.Parse("2006-01-02", startDateStr)
		if err == nil {
			startDate = parsedStartDate
		}
	}

	if endDateStr != "" {
		parsedEndDate, err := time.Parse("2006-01-02", endDateStr)
		if err == nil {
			endDate = parsedEndDate.AddDate(0, 0, 1) // Include the end date
		}
	}

	histogram, err := c.runModel.GetWeeklyHistogram(userID, startDate, endDate)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, histogram)
}

// GetMonthlyHistogram handles requests for monthly histogram data
func (c *RunController) GetMonthlyHistogram(ctx *gin.Context) {
	userID := ctx.Param("userId")
	if userID == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "userId is required"})
		return
	}

	// Parse date range parameters
	startDateStr := ctx.DefaultQuery("startDate", "")
	endDateStr := ctx.DefaultQuery("endDate", "")

	startDate := time.Now().AddDate(-1, 0, 0) // Default to last year
	endDate := time.Now()

	if startDateStr != "" {
		parsedStartDate, err := time.Parse("2006-01-02", startDateStr)
		if err == nil {
			startDate = parsedStartDate
		}
	}

	if endDateStr != "" {
		parsedEndDate, err := time.Parse("2006-01-02", endDateStr)
		if err == nil {
			endDate = parsedEndDate.AddDate(0, 0, 1) // Include the end date
		}
	}

	histogram, err := c.runModel.GetMonthlyHistogram(userID, startDate, endDate)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, histogram)
}

// GetYearlyHistogram handles requests for yearly histogram data
func (c *RunController) GetYearlyHistogram(ctx *gin.Context) {
	userID := ctx.Param("userId")
	if userID == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "userId is required"})
		return
	}

	// parse date range
	startDateStr := ctx.DefaultQuery("startDate", "")
	endDateStr := ctx.DefaultQuery("endDate", "")

	// default to last 5 years
	startDate := time.Now().AddDate(-5, 0, 0)
	endDate := time.Now()

	if startDateStr != "" {
		if d, err := time.Parse("2006-01-02", startDateStr); err == nil {
			startDate = d
		}
	}
	if endDateStr != "" {
		if d, err := time.Parse("2006-01-02", endDateStr); err == nil {
			endDate = d.AddDate(0, 0, 1) // inclusive
		}
	}

	histogram, err := c.runModel.GetYearlyHistogram(userID, startDate, endDate)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	ctx.JSON(http.StatusOK, histogram)
}

// GetRunStatistics handles requests for user's run statistics
func (c *RunController) GetRunStatistics(ctx *gin.Context) {
	userID := ctx.Param("userId")
	if userID == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "userId is required"})
		return
	}

	stats, err := c.runModel.GetTotalStats(userID)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, stats)
}
