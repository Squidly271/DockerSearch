#!/bin/bash

docker search --no-trunc=true --automated=true $1 > /tmp/search

LINENUM="0"

echo "<b><font size=14>Search results for $1</font></b>"
echo ""
cat /tmp/search | while read LINE
do
	if [ "$LINENUM" -eq "0" ]
	then
#		echo -e "\t\t\t\t$LINE"
#		echo -e ""

		LINENUM="1"
		continue
	else

		REPOSITORY=$(echo "$LINE" | cut -d " " -f1)
		EVERYTHINGELSE=$(echo "$LINE" | sed 's/[^ ]* //' | sed 's/.\{25\}$//')
		echo "<font size=3><u><a href=\"https://registry.hub.docker.com/u/$REPOSITORY\" target=\"_blank\">https://registry.hub.docker.com/u/$REPOSITORY</a></u></font><span style='color: #E80000;'> $EVERYTHINGELSE</span> "
		echo ""
	fi

done
echo "</table>"
echo ""
echo "Clicking the link will take you to the associated docker page."
echo ""
echo "Copy the link address, close the window and paste it into the \"Convert\" text box to convert the Docker File to an XML template for use in unRAID"
echo ""

