package models

type Friend struct {
    UID string `bson:"uid" json:"uid"`
    Messages []Message `bson:"messages" json:"messages"`
	Games []string `bson:"games" json:"games"`
}

type FriendRequest struct {
	From string `bson:"from" json:"from"`
	To   string `bson:"to" json:"to"`
}