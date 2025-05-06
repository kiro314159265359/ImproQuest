package services

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"
	"time"

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
			log.Printf("Error reading message: %v", err)
			break
		}

		// Process run data
		if messageType == websocket.TextMessage {
			var runData models.RunData
			if err := json.Unmarshal(p, &runData); err != nil {
				log.Printf("Error unmarshaling run data: %v", err)
				continue
			}

			// Ensure userID is set
			runData.UserID = userID
			if runData.Timestamp.IsZero() {
				runData.Timestamp = time.Now()
			}

			// Store in MongoDB time series collection
			if err := manager.runModel.SaveRun(&runData); err != nil {
				log.Printf("Error storing run data: %v", err)
				if err := conn.WriteMessage(websocket.TextMessage, []byte("error: "+err.Error())); err != nil {
					log.Printf("Error sending error message: %v", err)
				}
				continue
			}

			// Acknowledge receipt
			if err := conn.WriteMessage(websocket.TextMessage, []byte("data received")); err != nil {
				log.Printf("Error acknowledging: %v", err)
			}
		}
	}
}
