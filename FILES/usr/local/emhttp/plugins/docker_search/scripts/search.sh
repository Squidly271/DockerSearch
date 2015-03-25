#!/bin/bash


function OutputResults {

LINENUM="0"

cat /tmp/search | while read LINE
do
        if [ "$LINENUM" -eq "0" ]
        then
# Output the header line
                LINENUM="1"
		HEADERLINE=$(echo "$LINE" | sed 's/.\{9\}$//')
		echo "<center><pre><code><font size=4><strong>                                  $HEADERLINE</strong></font></pre></code>"
		echo "<hr />"
                continue
        else
                REPOSITORY=$(echo "$LINE" | cut -d " " -f1)
       	        EVERYTHINGELSE=$(echo "$LINE" | sed 's/[^ ]* //' | sed 's/.\{4\}$//')
               	echo "<center><pre><code><font size=4><u><a href=\"https://registry.hub.docker.com/u/$REPOSITORY\" target=\"_blank\">https://registry.hub.docker.com/u/$REPOSITORY</a></u><span style='color: #E80000;'> $EVERYTHINGELSE</span></pre></code></pre></center>"

		if [[ $LINE != *"[OK]"* ]]
		then
			echo "<span style='color: #E80000;'>Incompatible with the conversion engine</span>"
		fi

#		echo ""
        fi

done

echo "</font>"
}

# Main Program


# kill any error messages from docker search
exec 2>/dev/null

# docker search only allows one word to be searched for - grr
DOCKERSEARCHTERM="$1"

docker search --no-trunc=false --automated=true "$DOCKERSEARCHTERM" > /tmp/search

RESULTS=$(grep -c ^ /tmp/search)
RESULTS=$((RESULTS-1))

# Combine all search parameters into one line

NICESEARCHTERM="$*"

# Convert search term to lower case, and replace spaces with +

SEARCHTERM="$(echo "$NICESEARCHTERM" | tr '[:upper:]' '[:lower:]' | sed -e 's/ /+/g')"

echo "<center><img src=/plugins/docker_search/images/dockerlogo.png></center>"

if [ $RESULTS = -1 ]
then
	echo "<center><b><p><font size=6>Invalid Search Term \"$NICESEARCHTERM\"</font></p></b><center>"

	exit
fi

if [ $RESULTS = 0 ]
then
	echo "<center><b><p><font size=6>There were no results for \"$NICESEARCHTERM\"</font></p></b></center>"
	echo "<center><font size =4>For full search results, click  <u><a href=\"https://registry.hub.docker.com/search?q=$SEARCHTERM&s=stars\" target=\"_blank\">HERE</a></u>"
        echo "<center><font size =4>Or try broadening your search criteria</center>"

        exit
fi

echo "<center><b><p><font size=4>Condensed Search results for \"$NICESEARCHTERM\": $RESULTS </font></p></b></center>"

echo "<center><font size =4>For full search results, click  <u><a href=\"https://registry.hub.docker.com/search?q=$SEARCHTERM&s=stars\" target=\"_blank\">HERE</a></u>"

echo "<hr />"

OutputResults

echo "<center><font size=3>Clicking the link will take you to the associated docker page.</center>"
echo "<center><font size=3>Copy the link address, close the window and paste it into the \"Convert\" text box to convert the Docker File to an XML template for use in unRAID</center>"
echo "<hr />"
echo "<center><font size =4>For full search results, click  <u><a href=\"https://registry.hub.docker.com/search?q=$SEARCHTERM&s=stars\" target=\"_blank\">HERE</a></u>"

echo "<div style=\"text-align: right; direction: ltr; margin-left: 1em;\"><img src=/plugins/docker_search/images/Chode_300.gif></div>"

