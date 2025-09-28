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
	"go.mongodb.org/mongo-driver/mongo/options"
)

func handleStartGameUpdate(update models.Update) {
	game := updateToGame(update)

	_, err := mongoClient.GameCollection.UpdateOne(
		ctx,
		bson.M{"gameId": game.GameID},
		bson.M{"$setOnInsert": game},
		options.Update().SetUpsert(true),
	)
	if err != nil {
		log.Println("Failed upserting game:", err)
		return
	}

	type pair struct{ u, f string }
	for _, p := range []pair{{update.From, update.To}, {update.To, update.From}} {
		filter := bson.M{"uid": p.u, "friends.uid": p.f}
		updateDoc := bson.M{"$addToSet": bson.M{"friends.$.games": game.GameID}}
		if _, uErr := mongoClient.UserCollection.UpdateOne(ctx, filter, updateDoc); uErr != nil {
			if uErr == mongo.ErrNoDocuments {
				log.Printf("Friend relationship missing for user %s -> %s while adding game %s", p.u, p.f, game.GameID)
			} else {
				log.Println("Failed updating friend games:", uErr)
			}
		}
	}

	key := fmt.Sprintf("user:%s:online", update.From)
	if rErr := redis.RedisClient.Set(ctx, key, "1", time.Minute).Err(); rErr != nil {
		log.Println("Redis set online error:", rErr)
	}
	payload, mErr := json.Marshal(update)
	if mErr != nil {
		log.Println("Marshal start game update failed:", mErr)
		return
	}
	if pubErr := redis.RedisClient.Publish(ctx, "status_channel", ""); pubErr != nil {
		log.Println("Publish status_channel failed:", pubErr)
	}
	if pubErr := redis.RedisClient.Publish(ctx, "start_game_channel", payload); pubErr != nil {
		log.Println("Publish start_game_channel failed:", pubErr)
	}
}