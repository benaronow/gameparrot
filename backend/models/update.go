package models

type UpdateType string
const (
	UpdateTypeMessage UpdateType = "message"
	UpdateTypeFriendRequest UpdateType = "friend_request"
	UpdateTypeFriendAccept UpdateType = "friend_accept"
)

type Update struct {
	Type UpdateType `json:"type"`
	From string `json:"from,omitempty"`
	To string `json:"to,omitempty"`
	Message string `json:"message,omitempty"`
	Status []User `json:"status,omitempty"`
}