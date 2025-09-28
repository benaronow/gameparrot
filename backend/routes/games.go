package routes

import (
	"context"
	"encoding/json"
	"gameparrot_backend/models"
	mongoClient "gameparrot_backend/mongo"
	"net/http"
	"strings"
	"sync"
	"time"
)

func GamesHandler(w http.ResponseWriter, r *http.Request) {
	raw := r.URL.Query().Get("gids")
	if raw == "" {
		w.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(w).Encode(map[string]string{"error": "missing gids query param"})
		return
	}

	gameIds := strings.Split(raw, "s")
	if len(gameIds) == 0 {
		w.WriteHeader(http.StatusOK)
		_ = json.NewEncoder(w).Encode(map[string]any{"games": []models.TurnGame{}})
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	games := make([]models.TurnGame, 0, len(gameIds))
	var mu sync.Mutex
	var wg sync.WaitGroup

	for _, id := range gameIds {
		gameId := id
		wg.Add(1)
		go func() {
			defer wg.Done()
			var game models.TurnGame
			err := mongoClient.GameCollection.FindOne(ctx, map[string]any{"gameId": gameId}).Decode(&game)
			if err != nil {
				return
			}
			mu.Lock()
			games = append(games, game)
			mu.Unlock()
		}()
	}

	doneCh := make(chan struct{})
	go func() {
		wg.Wait()
		close(doneCh)
	}()

	select {
	case <-ctx.Done():
	case <-doneCh:
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(map[string]any{"games": games})
}