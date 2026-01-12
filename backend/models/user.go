package models

type User struct {
    UID string `bson:"uid" json:"uid"`
    Email string `bson:"email" json:"email"`
    Friends []Friend `bson:"friends" json:"friends"`
	FriendRequests []FriendRequest `bson:"friend_requests" json:"friend_requests"`
    Online bool `json:"online"`
}