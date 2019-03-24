#!/bin/bash

#Author Jakub Tolinski
#nr indeksu 439493

LOCATION=POZNAN
KEY=$APIXUKEY

MODE=C
LASTMOD=
TIME_DIFF=300
DYNAMIC_UPDATE=0
ITS=0


if [ -z $KEY ]
	then
		echo 'Prosze wprowadzic zmienna srodowiskowa APIXUKEY'
		exit 1
	fi


while getopts ":dfl:" OPTION
do
case $OPTION in
	l) LOCATION=$OPTARG ;;
	d) DYNAMIC_UPDATE=1 ;;
	f) MODE=F ;;
	\?)
	echo "Nieprawidlowa opcja -$OPTARG" >&2
	exit 1 ;;
	:)
	echo "opcja -$OPTARG wymaga podania argumentu" >&2
	exit 1;;
	esac
done


while [[ 1 == 1 ]]
do

if [[ $DYNAMIC_UPDATE == 1 ]]
	then
		echo "Tryb Dynamic Update aktywny "
		echo "Czas ostatniej aktualizacji: $(date +%H-%M-%S)"

fi
LASTMOD=$(stat -c %Y /tmp/$LOCATION 2> /dev/null )
STATUS_FILE=$?
CURR_TIME=$(date "+%s")

if [[ $STATUS_FILE==1 && $(($LASTMOD + $TIME_DIFF)) -lt $CURR_TIME ]]
then
	curl -s "http://api.apixu.com/v1/current.json?key=$KEY&q=$LOCATION" | jq .'' > /tmp/$LOCATION
fi


if [[ $MODE == C ]]
	then
	WEATHER=$(cat /tmp/$LOCATION | jq '.current'| jq '.condition' | jq -r '.text')
	TEMP=$(cat /tmp/$LOCATION | jq '.current'| jq -r '.temp_c')
	TEMPFEEL=$(cat /tmp/$LOCATION | jq '.current'| jq -r '.feelslike_c')
	PRESSURE=$(cat /tmp/$LOCATION | jq '.current'| jq -r '.pressure_mb')
	WINDSPEED=$(cat /tmp/$LOCATION | jq '.current'| jq -r '.wind_kph')
	HUMIDITY=$(cat /tmp/$LOCATION | jq '.current'| jq -r '.humidity')
	echo "$LOCATION"
	echo "Pogoda obecnie: $WEATHER"
	echo "Temperatura wynosi $TEMP C"
	echo "Temperatura odczuwalna wynosi: $TEMPFEEL C"
	echo "Predkosc wiatru wynosi $WINDSPEED KPH"
	echo "Cisnienie wynosi $PRESSURE hPa"
	echo "Wilgotnosc wynosi $HUMIDITY %"
else
	WEATHER=$(cat /tmp/$LOCATION | jq '.current'| jq '.condition' | jq -r '.text')
	TEMP=$(cat /tmp/$LOCATION | jq '.current'| jq -r '.temp_f')
	WINDSPEED=$(cat /tmp/$LOCATION | jq '.current'| jq -r '.wind_mph')
	TEMPFEEL=$(cat /tmp/$LOCATION | jq '.current'| jq -r '.feelslike_f')
	PRESSURE=$(cat /tmp/$LOCATION | jq '.current'| jq -r '.pressure_mb')
	HUMIDITY=$(cat /tmp/$LOCATION | jq '.current'| jq -r '.humidity')
	echo "$LOCATION"
	echo "Pogoda obecnie: $WEATHER"
	echo "Temperatura wynosi $TEMP F"
	echo "Temperatura odczuwalna wynosi: $TEMPFEEL F"
	echo "Predkosc wiatru wynosi $WINDSPEED MPH"
	echo "Cisnienie wynosi $PRESSURE hPa"
	echo "Wilgotnosc wynosi $HUMIDITY %"
fi


if [[ $DYNAMIC_UPDATE == 0 ]]
	then
	exit 0
fi

sleep $TIME_DIFF

echo -en "\e[9A"



done
exit 0
