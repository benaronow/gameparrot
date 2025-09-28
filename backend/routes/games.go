package routes

import (
	"context"
	"encoding/json"
	"gameparrot_backend/models"
	mongoClient "gameparrot_backend/mongo"
	"net/http"
	"runtime"
	"sync"
	"time"
)

func GamesHandler(w http.ResponseWriter, r *http.Request) {
	uid := r.URL.Query().Get("uid")
	var user models.User
	err := mongoClient.UserCollection.FindOne(ctx, map[string]any{"uid": uid}).Decode(&user)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		_ = json.NewEncoder(w).Encode(map[string]string{"error": "user could not be accessed"})
		return
	}

	gameIds := []string{}
	fid := r.URL.Query().Get("fid")
	for _, friend := range user.Friends {
		if friend.UID == fid {
			gameIds = friend.Games
			break
		}
	}
	if len(gameIds) == 0 {
		w.WriteHeader(http.StatusOK)
		_ = json.NewEncoder(w).Encode(map[string]any{"games": []models.TurnGame{}})
		return
	}

	timeoutCtx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	results := make([]models.TurnGame, len(gameIds))
	succeeded := make([]bool, len(gameIds))

	maxDefault := runtime.GOMAXPROCS(0) * 4
	poolSize := min(16, maxDefault, len(gameIds))
	if poolSize == 0 {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_ = json.NewEncoder(w).Encode(map[string]any{"games": []models.TurnGame{}})
		return
	}

	type job struct{ idx int; id string }
	jobs := make(chan job)
	var wg sync.WaitGroup

	worker := func() {
		defer wg.Done()
		for j := range jobs {
			if timeoutCtx.Err() != nil {
				return
			}
			var game models.TurnGame
			err := mongoClient.GameCollection.FindOne(timeoutCtx, map[string]any{"gameId": j.id}).Decode(&game)
			if err == nil {
				results[j.idx] = game
				succeeded[j.idx] = true
			}
		}
	}

	for range poolSize {
		wg.Add(1)
		go worker()
	}

	go func() {
		for i, id := range gameIds {
			if timeoutCtx.Err() != nil {
				break
			}
			jobs <- job{idx: i, id: id}
		}
		close(jobs)
	}()

	wg.Wait()

	games := make([]models.TurnGame, 0, len(gameIds))
	for i, ok := range succeeded {
		if ok {
			games = append(games, results[i])
		}
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(map[string]any{"games": games})
}