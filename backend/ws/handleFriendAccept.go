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

func handleFriendAcceptUpdate(update models.Update) {
	friendRequest := updateToFriendRequest(update)

	newFriendFrom := models.Friend{UID: update.To, Messages: []models.Message{}, Games: []string{}}
	newFriendTo := models.Friend{UID: update.From, Messages: []models.Message{}, Games: []string{}}

	if _, err := mongoClient.UserCollection.UpdateOne(ctx, bson.M{"uid": update.From}, bson.M{"$pull": bson.M{"friend_requests": bson.M{"from": friendRequest.From, "to": friendRequest.To}}}); err != nil {
		if err == mongo.ErrNoDocuments { log.Println("Could not find from user"); return } else { log.Println("Friend accept pull (from) failed:", err); return }
	}
	if _, err := mongoClient.UserCollection.UpdateOne(ctx, bson.M{"uid": update.From}, bson.M{"$addToSet": bson.M{"friends": newFriendFrom}}); err != nil {
		log.Println("Friend accept add friend (from) failed:", err); return
	}

	if _, err := mongoClient.UserCollection.UpdateOne(ctx, bson.M{"uid": update.To}, bson.M{"$pull": bson.M{"friend_requests": bson.M{"from": friendRequest.From, "to": friendRequest.To}}}); err != nil {
		if err == mongo.ErrNoDocuments { log.Println("Could not find to user"); return } else { log.Println("Friend accept pull (to) failed:", err); return }
	}
	if _, err := mongoClient.UserCollection.UpdateOne(ctx, bson.M{"uid": update.To}, bson.M{"$addToSet": bson.M{"friends": newFriendTo}}); err != nil {
		log.Println("Friend accept add friend (to) failed:", err); return
	}

	key := fmt.Sprintf("user:%s:online", update.To)
	if rErr := redis.RedisClient.Set(ctx, key, "1", time.Minute).Err(); rErr != nil { log.Println("Redis set online error:", rErr) }
	payload, mErr := json.Marshal(update); if mErr != nil { log.Println("Marshal friend accept update failed:", mErr); return }
	if pubErr := redis.RedisClient.Publish(ctx, "status_channel", ""); pubErr != nil { log.Println("Publish status_channel failed:", pubErr) }
	if pubErr := redis.RedisClient.Publish(ctx, "friend_accept_channel", payload); pubErr != nil { log.Println("Publish friend_accept_channel failed:", pubErr) }
}