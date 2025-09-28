package ws

import (
	"context"
	"gameparrot_backend/models"
	"os/exec"
	"log"
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

func updateToGame(update models.Update) (models.TurnGame, error) {
	gameId, err := exec.Command("uuidgen").Output()
	if err != nil {
		log.Println(err)
		return models.TurnGame{}, err;
	}
	
	return models.TurnGame{
		GameID: string(gameId),
		GameType: models.GameType(update.Message),
		Turns: []models.Turn{},
		CurrentPlayer: update.To,
		Finished: false,
		Winner: "",
	}, nil
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