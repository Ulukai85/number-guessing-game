#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --no-align -t -c"
SECRET_NUMBER=$((1 + ($RANDOM % 1000)))

echo -e "\n~~~~~~ Number Guessing Game ~~~~~~\n"
echo -e "Enter your username:"
read PLAYER_NAME

GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE name='$PLAYER_NAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE name='$PLAYER_NAME'")

if [[ -z  $BEST_GAME ]]
then
  echo -e "Welcome, $PLAYER_NAME! It looks like this is your first time here."
  INSERT_PLAYER=$($PSQL "INSERT INTO players(name, games_played) VALUES('$PLAYER_NAME', 0)")
else
  echo -e "\nWelcome back, $PLAYER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

NUMBER_OF_GUESSES=1
echo -e "Guess the secret number between 1 and 1000:"
read GUESS

while [ $GUESS != $SECRET_NUMBER ]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "That is not an integer, guess again:"
  else
    if [ "$GUESS" -lt "$SECRET_NUMBER" ]
    then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi
  fi
  ((NUMBER_OF_GUESSES++))
  read GUESS
done

((GAMES_PLAYED++))

if [[ -z $BEST_GAME ]]
then
  BEST_GAME=$NUMBER_OF_GUESSES
fi

if [ "$BEST_GAME" -gt "$NUMBER_OF_GUESSES" ]
then
  BEST_GAME=$NUMBER_OF_GUESSES
fi

INSERT_PLAYER_RESULT=$($PSQL "UPDATE players SET games_played = '$GAMES_PLAYED', best_game ='$BEST_GAME' WHERE name = '$PLAYER_NAME'")
echo -e "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"


