#!/bin/bash


function OutputResults {

LINENUM="0"

cat /tmp/search | while read LINE
do
        if [ "$LINENUM" -eq "0" ]
        then
# don't output the header line
                LINENUM="1"
                continue
        else
                REPOSITORY=$(echo "$LINE" | cut -d " " -f1)
       	        EVERYTHINGELSE=$(echo "$LINE" | sed 's/[^ ]* //' | sed 's/.\{25\}$//')
               	echo "<font size=3><u><a href=\"https://registry.hub.docker.com/u/$REPOSITORY\" target=\"_blank\">https://registry.hub.docker.com/u/$REPOSITORY</a></u></font><span style='color: #E80000;'> $EVERYTHINGELSE</span> "

		if [[ $LINE != *"[OK]"* ]]
		then
			echo "<span style='color: #E80000;'>Incompatible with the conversion engine</span>"
		fi

		echo ""
        fi

done
}

exec 2>/dev/null
docker search --no-trunc=true --automated=true $1 > /tmp/search

RESULTS=$(grep -c ^ /tmp/search)
RESULTS=$((RESULTS-1))

if [ $RESULTS = -1 ]
then
	echo "<b><p><font size=6>Invalid Search Term</font></p></b>"
	exit
fi

echo "<img src=/plugins/docker_search/images/dockerlogo.png>"
echo "<b><p><font size=6>Search results for $1: $RESULTS</font></p>"
echo "Search results may be limited by docker search.  More results may be available at on Docker's website<br>"
echo "<hr />"

OutputResults

echo "<hr />"
echo "Clicking the link will take you to the associated docker page."
echo ""
echo "Copy the link address, close the window and paste it into the \"Convert\" text box to convert the Docker File to an XML template for use in unRAID"
echo ""

