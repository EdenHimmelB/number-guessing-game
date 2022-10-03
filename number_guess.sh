#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


NUMBER=$((RANDOM % 1000 + 1))
echo Enter your username:
read NAME

ID=$($PSQL "SELECT user_id FROM users WHERE name = '$NAME'")
if [[ -z $ID ]]; then
    echo -e "\nWelcome, $NAME! It looks like this is your first time here."
    INSERT_NEW_USER=$($PSQL "INSERT INTO users(name) VALUES('$NAME')")
    ID=$($PSQL "SELECT user_id FROM users WHERE name = '$NAME'")
else
    NAME=$($PSQL "SELECT name FROM users WHERE user_id = $ID")
    RETURNER=$($PSQL "SELECT COUNT(*), MIN(guesses) FROM record WHERE user_id = $ID")
    echo $RETURNER | while IFS="|" read GAMES BEST; do
        echo "Welcome back, $NAME! You have played $GAMES games, and your best game took $BEST guesses."
    done
fi

TRY=0

echo "Guess the secret number between 1 and 1000:"
while read GUESS_NUM; do
    if [[ "$GUESS_NUM" =~ ^[0-9]+$ ]]; then
        if [[ $GUESS_NUM -lt $NUMBER ]]; then
            TRY=$((TRY += 1))
            echo "It's higher than that, guess again: "
        else
            if [[ $GUESS_NUM -gt $NUMBER ]]; then
                TRY=$((TRY += 1))
                echo "It's lower than that, guess again: "
            else
                TRY=$((TRY += 1))
                INSERT_GAME_RESULT=$($PSQL "INSERT INTO record(user_id, guesses) VALUES($ID, $TRY)")
                break;
            fi
        fi
    else
        echo "That is not an integer, guess again:"
    fi
done

echo -e "You guessed it in $TRY tries. The secret number was $NUMBER. Nice job!"