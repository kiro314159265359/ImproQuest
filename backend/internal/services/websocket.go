package services

import (
	"encoding/json"
	"log"
	"net/http"
	"strings"
	"sync"
	"time"
	"unicode"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"

	"github.com/HarDizzeR/Project/backend/internal/models" // Replace with your actual import path
)

var (
	upgrader = websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
		CheckOrigin: func(r *http.Request) bool {
			return true // Allow all connections in development
		},
	}
)

// WebSocketManager handles WebSocket connections
type WebSocketManager struct {
	clients  map[*websocket.Conn]string // map conn to userID
	mutex    sync.Mutex
	runModel *models.RunModel
}

// NewWebSocketManager creates a new WebSocket manager
func NewWebSocketManager(runModel *models.RunModel) *WebSocketManager {
	return &WebSocketManager{
		clients:  make(map[*websocket.Conn]string),
		runModel: runModel,
	}
}

// HandleConnection handles a new WebSocket connection
func (manager *WebSocketManager) HandleConnection(c *gin.Context) {
	userID := c.Query("userId")
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "userId is required"})
		return
	}

	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Printf("Failed to set websocket upgrade: %v", err)
		return
	}
	defer conn.Close()

	// Register client
	manager.mutex.Lock()
	manager.clients[conn] = userID
	manager.mutex.Unlock()

	// Handle disconnection
	defer func() {
		manager.mutex.Lock()
		delete(manager.clients, conn)
		manager.mutex.Unlock()
	}()
	for {
		messageType, p, err := conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("Error reading message (unexpected close): %v", err)
			} else {
				log.Printf("Error reading message (client likely disconnected): %v", err)
			}
			break
		}

		// We are typically interested in text messages for this kind of protocol
		if messageType != websocket.TextMessage {
			log.Printf("Received non-text message type: %d", messageType)
			continue
		}

		messageStr := string(p)
		log.Printf("Received raw message (length %d) from userID %s: [%s]", len(messageStr), userID, messageStr)

		trimmedMessageStr := strings.TrimLeftFunc(messageStr, unicode.IsSpace)
		if len(trimmedMessageStr) < len(messageStr) {
			log.Printf("Trimmed message for prefix check (original length %d, new length %d) from userID %s: [%s]", len(messageStr), len(trimmedMessageStr), userID, trimmedMessageStr)
		}

		expectedPrefix := "SendRun, "

		if !strings.HasPrefix(trimmedMessageStr, expectedPrefix) {
			errMsg := "error: invalid format. Message must start with '" + expectedPrefix + "'"
			log.Printf(errMsg+" (Original raw message from userID %s was: '"+messageStr+"', Trimmed message was: '"+trimmedMessageStr+"')", userID)
			if err := conn.WriteMessage(websocket.TextMessage, []byte(errMsg)); err != nil {
				log.Printf("Error sending error message to userID %s: %v", userID, err)
			}
			continue
		}

		jsonPart := strings.TrimPrefix(trimmedMessageStr, expectedPrefix)

		var runData models.RunData
		if err := json.Unmarshal([]byte(jsonPart), &runData); err != nil {
			log.Printf("Error unmarshaling run data from userID %s (json part: '%s'): %v", userID, jsonPart, err)
			if err := conn.WriteMessage(websocket.TextMessage, []byte("error: invalid JSON format. Details: "+err.Error())); err != nil {
				log.Printf("Error sending JSON format error message to userID %s: %v", userID, err)
			}
			continue
		}

		runData.UserID = userID
		if runData.Timestamp.IsZero() {
			runData.Timestamp = time.Now().UTC()
			log.Printf("Run data from userID %s had zero timestamp, set to current time: %s", userID, runData.Timestamp)
		}

		// Store in MongoDB time series collection
		if err := manager.runModel.SaveRun(&runData); err != nil {
			log.Printf("Error storing run data for userID %s: %v", userID, err)
			// Be careful about sending raw db errors to client, might expose too much.
			// Consider a generic error message or mapping to user-friendly errors.
			if errResp := conn.WriteMessage(websocket.TextMessage, []byte("error: could not save run data")); errResp != nil {
				log.Printf("Error sending save data error message to userID %s: %v", userID, errResp)
			}
			continue
		}

		log.Printf("Successfully processed and stored run data for userID %s: %+v", userID, runData)

		// Acknowledge receipt
		if err := conn.WriteMessage(websocket.TextMessage, []byte("data received and processed")); err != nil {
			log.Printf("Error acknowledging receipt to userID %s: %v", userID, err)
		}
	}
}
