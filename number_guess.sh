#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --no-align -t -c"

echo "Enter your username:"
read USERNAME

USERNAME_QUERY_RESULT=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")

if [[ -z $USERNAME_QUERY_RESULT ]]
  then
    echo Welcome, $USERNAME! It looks like this is your first time here.
    NUMBER_OF_GAMES=0
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 0)")
else
  IFS='|'
  read -ra ARRAY <<< $USERNAME_QUERY_RESULT
  unset IFS
  NUMBER_OF_GAMES=${ARRAY[2]}
  BEST_GAME=${ARRAY[3]}
  echo Welcome back, $USERNAME! You have played $NUMBER_OF_GAMES games, and your best game took $BEST_GAME guesses.
fi

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"
read GUESS

NUMBER_OF_GUESSES=1

while [[ $GUESS != $SECRET_NUMBER ]]
do
  if ! [[ "$GUESS" =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read GUESS
    NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
  else
    echo "It's higher than that, guess again:"
    read GUESS
    NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
  fi
done

echo You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!

UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE username='$USERNAME'")

if [[ -z $BEST_GAME ]] || [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
fi
