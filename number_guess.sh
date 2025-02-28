#!/bin/bash

DB_FILE="game_database.txt"

# Generate a random number for guessing game
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Prompt user for username
echo -n "Enter your username: "
read USERNAME

# Ensure username is at most 22 characters
USERNAME=$(echo $USERNAME | cut -c1-22)

# Check if username exists in database
if grep -q "^$USERNAME," "$DB_FILE"; then
    # Fetch user data
    USER_DATA=$(grep "^$USERNAME," "$DB_FILE")
    GAMES_PLAYED=$(echo "$USER_DATA" | cut -d',' -f2)
    BEST_GAME=$(echo "$USER_DATA" | cut -d',' -f3)
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    GAMES_PLAYED=0
    BEST_GAME=9999
fi

# Start guessing game
echo "Guess the secret number between 1 and 1000:"
GUESS_COUNT=0

while true; do
    read GUESS

    # Check if input is a valid integer
    if ! [[ "$GUESS" =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
        continue
    fi

    GUESS_COUNT=$((GUESS_COUNT + 1))

    if (( GUESS < SECRET_NUMBER )); then
        echo "It's higher than that, guess again:"
    elif (( GUESS > SECRET_NUMBER )); then
        echo "It's lower than that, guess again:"
    else
        echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
        break
    fi
done

# Update user stats in database
GAMES_PLAYED=$((GAMES_PLAYED + 1))
if (( GUESS_COUNT < BEST_GAME )); then
    BEST_GAME=$GUESS_COUNT
fi

# Save or update user data
grep -v "^$USERNAME," "$DB_FILE" > temp_db.txt
echo "$USERNAME,$GAMES_PLAYED,$BEST_GAME" >> temp_db.txt
mv temp_db.txt "$DB_FILE"
