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

func handleFriendRequestUpdate(update models.Update) {
	friendRequest := updateToFriendRequest(update)

	updateDoc := bson.M{"$addToSet": bson.M{"friend_requests": friendRequest}}
	if _, err := mongoClient.UserCollection.UpdateOne(ctx, bson.M{"uid": update.From}, updateDoc); err != nil {
		if err == mongo.ErrNoDocuments { log.Println("Could not find from user"); return }
		log.Println("Friend request update (from user) failed:", err); return
	}
	if _, err := mongoClient.UserCollection.UpdateOne(ctx, bson.M{"uid": update.To}, updateDoc); err != nil {
		if err == mongo.ErrNoDocuments { log.Println("Could not find to user"); return }
		log.Println("Friend request update (to user) failed:", err); return
	}

	key := fmt.Sprintf("user:%s:online", update.From)
	if rErr := redis.RedisClient.Set(ctx, key, "1", time.Minute).Err(); rErr != nil {
		log.Println("Redis set online error:", rErr)
	}
	payload, mErr := json.Marshal(update)
	if mErr != nil { log.Println("Marshal friend request update failed:", mErr); return }
	if pubErr := redis.RedisClient.Publish(ctx, "status_channel", ""); pubErr != nil { log.Println("Publish status_channel failed:", pubErr) }
	if pubErr := redis.RedisClient.Publish(ctx, "friend_request_channel", payload); pubErr != nil { log.Println("Publish friend_request_channel failed:", pubErr) }
}