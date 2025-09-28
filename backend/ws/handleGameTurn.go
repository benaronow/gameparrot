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
	"go.mongodb.org/mongo-driver/mongo"
)

func handleGameTurnUpdate(update models.Update) {
	turn := updateToTurn(update)

	var game models.TurnGame
	err := mongoClient.GameCollection.FindOne(ctx, map[string]any{"gameId": update.GameID}).Decode(&game)
	if err == mongo.ErrNoDocuments {
		log.Println("Could not find game")
		return
	}
	game.Turns = append(game.Turns, turn)
	game.CurrentPlayer = update.To
	gameUpdate := bson.M{
		"$set": bson.M{
			"turns": game.Turns,
			"currentPlayer": game.CurrentPlayer,
		},
	}
	_, err = mongoClient.GameCollection.UpdateOne(ctx, map[string]any{"gameId": game.GameID}, gameUpdate)
	if err != nil {
		log.Println("Could not update game");
		return;
	}

	key := fmt.Sprintf("user:%s:online", update.To)
	err = redis.RedisClient.Set(ctx, key, "1", time.Minute).Err()
	gameTurnString, gameTurnErr := json.Marshal(update)
	if err != nil || gameTurnErr != nil {
		log.Println("Redis set online error:", err)
	} else {
		redis.RedisClient.Publish(ctx, "status_channel", "")
		redis.RedisClient.Publish(ctx, "game_turn_channel", gameTurnString)
	}
}