package ws

import (
	"encoding/json"
	"fmt"
	"gameparrot_backend/models"
	mongoClient "gameparrot_backend/mongo"
	"gameparrot_backend/redis"
	"log"
	"time"

	"go.mongodb.org/mongo-driver/bson"
)

func handleGameTurnUpdate(update models.Update) {
	turn := updateToTurn(update)

	if update.GameID == "" { log.Println("Missing GameID in turn update"); return }
	res, err := mongoClient.GameCollection.UpdateOne(ctx,
		bson.M{"gameId": update.GameID},
		bson.M{"$push": bson.M{"turns": turn}, "$set": bson.M{"currentPlayer": update.To}},
	)
	if err != nil {
		log.Println("Game turn atomic update failed:", err); return
	}
	if res.MatchedCount == 0 { log.Println("Could not find game for turn update"); return }

	key := fmt.Sprintf("user:%s:online", update.From)
	if rErr := redis.RedisClient.Set(ctx, key, "1", time.Minute).Err(); rErr != nil { log.Println("Redis set online error:", rErr) }
	payload, mErr := json.Marshal(update); if mErr != nil { log.Println("Marshal game turn update failed:", mErr); return }
	if pubErr := redis.RedisClient.Publish(ctx, "status_channel", ""); pubErr != nil { log.Println("Publish status_channel failed:", pubErr) }
	if pubErr := redis.RedisClient.Publish(ctx, "game_turn_channel", payload); pubErr != nil { log.Println("Publish game_turn_channel failed:", pubErr) }
}