package models

type GameType string
const (
	GameTypeTicTacToe GameType = "ticTacToe"
)

type Turn struct {
	Player string `bson:"player" json:"player"`
	TurnInfo string `bson:"turnInfo" json:"turnInfo"`
}

type TurnGame struct {
	GameID string `bson:"gameId" json:"gameId"`
	GameType GameType `bson:"gameType" json:"gameType"`
	Turns []Turn `bson:"turns" json:"turns"`
	Initiator string `bson:"initiator" json:"initiator"`
	CurrentPlayer string `bson:"currentPlayer" json:"currentPlayer"`
	Winner string `bson:"winner" json:"winner"`
}