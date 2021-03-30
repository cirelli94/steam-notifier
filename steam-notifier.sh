#!/bin/bash

# pip install steamctl

if ! command -v steamctl &> /dev/null
then
    echo "steamctl could not be found"
    echo "install with `pip install steamctl`"
    echo "more here: https://github.com/ValvePython/steamctl"
    exit 1
fi

CONFIG="$HOME/.config/steam-notifier"

for GAME in $CONFIG/* ; do
	APPID=$(basename $GAME )
	steamctl -l quiet apps product_info $APPID > $GAME.json
	LAST=$( cat $GAME.json | jq .depots.branches.public.timeupdated | xargs echo )
	GAME_NAME=$( cat $GAME.json | jq .common.name )

	PREVIOUS=$(<$GAME)
	if [[ -z $PREVIOUS ]]; then
		PREVIOUS=0
	fi

	if (( (( $LAST - $PREVIOUS )) > 0 )); then
		WHEN=$( echo $LAST | xargs -I % sh -c 'date -d @%')

		notify-send "$GAME_NAME got an update on $WHEN!" --urgency=critical
		echo "$GAME_NAME got an update on $WHEN!" --urgency=critical

		echo $LAST > $GAME
	else
		echo "nothing new for $GAME_NAME :("
	fi

	rm $GAME.json
done

