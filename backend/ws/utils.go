package ws

import (
	"context"
	"gameparrot_backend/models"
)

var (
	ctx = context.Background()
)

func updateToMessage(update models.Update) models.Message {
	return models.Message{
		Message: update.Message,
		From: update.From,
		To: update.To,
	}
}

func updateToGame(update models.Update) models.TurnGame {
	return models.TurnGame{
		GameID: update.GameID,
		GameType: models.GameType(update.Message),
		Turns: []models.Turn{},
		Initiator: update.From,
		CurrentPlayer: update.To,
		Winner: "",
	}
}

func updateToTurn(update models.Update) models.Turn {
	return models.Turn{
		Player:  update.From,
		TurnInfo: update.Message,
	}
}

func updateToFriendRequest(update models.Update) models.FriendRequest {
	return models.FriendRequest{
		From: update.From,
		To: update.To,
	}
}