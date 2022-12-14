#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random number
RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))
# Ask for username
echo "Enter your username:"
read USERNAME
# Check if username is in database
USERNAME_DATABASE=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USERNAME_DATABASE ]]; then
# If not in database print [Welcome, <username>! It looks like this is your first time here.]
echo "Welcome, $USERNAME! It looks like this is your first time here."
else
# If in database print [Welcome back, <username>! You have played <games_played> games, and your best game took <best_game> guesses.]
GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USERNAME_DATABASE")
MIN_GUESSES=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USERNAME_DATABASE")
echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $MIN_GUESSES guesses."
fi
# Ask for user to guess number
echo "Guess the secret number between 1 and 1000:"
read NUMBER_INPUT
NUMBER_OF_TRIES=1
while [ $NUMBER_INPUT != $RANDOM_NUMBER ]; do
  # If not an integer
  if ! [[ $NUMBER_INPUT =~ ^[0-9]+$ ]];then
  echo "$NUMBER_INPUT That is not an integer, guess again:"
    read NUMBER_INPUT
  elif [[ $NUMBER_INPUT > $RANDOM_NUMBER ]]; then
  # If lower
  echo "It's lower than that, guess again:"
  NUMBER_OF_TRIES=$(($NUMBER_OF_TRIES+1))
  read NUMBER_INPUT
  elif [[ $NUMBER_INPUT < $RANDOM_NUMBER ]]; then
  # If higher
  echo "It's higher than that, guess again:"
  NUMBER_OF_TRIES=$(($NUMBER_OF_TRIES+1))
  read NUMBER_INPUT
  fi
done
if [[ $NUMBER_INPUT == $RANDOM_NUMBER ]]; then
  if [[ -z $USERNAME_DATABASE ]]; then
    INSERT_USERNAME_DATABASE=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME') ")
    USERNAME_DATABASE=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  fi
  INSERT_GAMES=$($PSQL "INSERT INTO games(user_id,guesses) VALUES($USERNAME_DATABASE,$NUMBER_OF_TRIES) ")
  echo "You guessed it in $NUMBER_OF_TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"
fi


# When number is guessed
