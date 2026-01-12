package models

type Message struct {
	Message string `bson:"message" json:"message"`
	From string `bson:"from" json:"from"`
	To string `bson:"to" json:"to"`
}