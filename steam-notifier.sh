#!/bin/bash

# sudo pip install steamctl

if ! command -v steamctl &> /dev/null ; then
    echo "missing dependency"
    echo "steamctl could not be found"
    echo "install with 'pip install steamctl'"
    echo "more here: https://github.com/ValvePython/steamctl"
    exit 1
fi

if ! command -v jq &> /dev/null ; then
    echo "missing dependency"
    echo "jq could not be found"
    echo "more here: https://stedolan.github.io/jq/"
    exit 1
fi

if ! command -v notify-send &> /dev/null ; then
    echo "missing dependency"
    echo "notify-send could not be found"
    echo "notify-send is provided by libnotify"
    exit 1
fi

CONFIG="$HOME/.config/steam-notifier"

for GAME in "$CONFIG"/* ; do
	APPID=$(basename "$GAME" )

	steamctl -l quiet apps product_info "$APPID" > "$GAME.json" || {
		notify-send "Failed steamctl with GAME: [$GAME] and APPID: [$APPID]" --urgency=critical
		echo "Failed steamctl with GAME: [$GAME] and APPID: [$APPID]" 
		rm "$GAME.json"
		continue 
	}

	LAST=$( jq -r .depots.branches.public.timeupdated < "$GAME.json" )
	GAME_NAME=$( jq -r .common.name < "$GAME.json" )

	PREVIOUS=$(<"$GAME")
	if [[ -z $PREVIOUS ]]; then
		PREVIOUS=0
	fi

	if (( (( LAST - PREVIOUS )) > 0 )); then
		WHEN=$( echo "$LAST" | xargs -I _ sh -c 'date +"%d %B %Y, %H:%I" -d @_')

		notify-send "$GAME_NAME got an update!" "On $WHEN" --urgency=critical --icon=steam
		echo "$GAME_NAME got an update on $WHEN!"

		if [ -v DISCORD_WEBHOOK ]; then
			echo "Send discord notification"
			curl "$DISCORD_WEBHOOK" \
				--request POST -H 'Content-Type: application/json' \
				--data-raw "{ \"username\": \"Steam Notifier\", \"content\": \"$GAME_NAME got an update! On $WHEN\" }";
		fi


		echo "$LAST" > "$GAME"
	else
		echo "Nothing new for $GAME_NAME :("
	fi

	rm "$GAME.json"
done
