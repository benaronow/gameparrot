package models

type GameType string
const (
	GameTypeTicTacToe GameType = "ticTacToe"
)

type Turn struct {
	Player string `bson:"player" json:"player"`
	TurnInfo string `bson:"turn_info" json:"turn_info"`
}

type TurnGame struct {
	GameID string `bson:"gameId" json:"gameId"`
	GameType GameType `bson:"gameType" json:"gameType"`
	Turns []Turn `bson:"turns" json:"turns"`
	CurrentPlayer string `bson:"currentPlayer" json:"currentPlayer"`
	Winner string `bson:"winner" json:"winner"`
}