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

func handleMessageUpdate(update models.Update) {
	message := updateToMessage(update);

	if _, err := mongoClient.UserCollection.UpdateOne(ctx,
		bson.M{"uid": update.From, "friends.uid": update.To},
		bson.M{"$push": bson.M{"friends.$.messages": message}},
	); err != nil {
		if err == mongo.ErrNoDocuments { log.Println("Could not find from user or friend relation") } else { log.Println("Message update (from) failed:", err) }
	}
	if _, err := mongoClient.UserCollection.UpdateOne(ctx,
		bson.M{"uid": update.To, "friends.uid": update.From},
		bson.M{"$push": bson.M{"friends.$.messages": message}},
	); err != nil {
		if err == mongo.ErrNoDocuments { log.Println("Could not find to user or friend relation") } else { log.Println("Message update (to) failed:", err) }
	}
	
	key := fmt.Sprintf("user:%s:online", update.From)
	if rErr := redis.RedisClient.Set(ctx, key, "1", time.Minute).Err(); rErr != nil { log.Println("Redis set online error:", rErr) }
	payload, mErr := json.Marshal(update); if mErr != nil { log.Println("Marshal message update failed:", mErr); return }
	if pubErr := redis.RedisClient.Publish(ctx, "status_channel", ""); pubErr != nil { log.Println("Publish status_channel failed:", pubErr) }
	if pubErr := redis.RedisClient.Publish(ctx, "message_channel", payload); pubErr != nil { log.Println("Publish message_channel failed:", pubErr) }
}