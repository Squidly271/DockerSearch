#!/bin/bash

docker search --no-trunc=true --automated=true $1 > /tmp/search

LINENUM="0"

echo "Search results for $1"
echo ""

cat /tmp/search | while read LINE
do
	if [ "$LINENUM" -eq "0" ]
	then
#		echo -e "\t\t\t\t$LINE"
		echo -e ""

		LINENUM="1"
		continue
	else

		REPOSITORY=$(echo "$LINE" | cut -d " " -f1)
		EVERYTHINGELSE=$(echo "$LINE" | sed 's/[^ ]* //')

		echo -e "<u><a href=\"https://registry.hub.docker.com/u/$REPOSITORY\" target=\"_blank\">https://registry.hub.docker.com/u/$REPOSITORY</a></u>"
		echo ""
	fi

done

echo ""
echo "Clicking the link will take you to the associated docker page."
echo ""
echo "Copy the link address, close the window and paste it into the \"Convert\" text box to convert the Docker File to an XML template for use in unRAID"
echo ""

