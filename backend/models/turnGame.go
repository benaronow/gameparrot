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
	GameID string `bson:"game_id" json:"gameId"`
	GameType GameType `bson:"game_type" json:"gameType"`
	Turns []Turn `bson:"turns" json:"turns"`
	CurrentPlayer string `bson:"current_player" json:"currentPlayer"`
	Finished bool `bson:"finished" json:"finished"`
	Winner string `bson:"winner" json:"winner"`
}