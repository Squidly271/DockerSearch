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

# kill any error messages from docker search
exec 2>/dev/null

SEARCHTERM=$1

# Convert search term to lower case.  Upper case is not allowed

SEARCHTERM="$(echo "$SEARCHTERM" | tr '[:upper:]' '[:lower:]')"

docker search --no-trunc=false --automated=true "$SEARCHTERM" > /tmp/search

RESULTS=$(grep -c ^ /tmp/search)
RESULTS=$((RESULTS-1))

echo "<center><img src=/plugins/docker_search/images/dockerlogo.png></center>"

if [ $RESULTS = -1 ]
then
	echo "<center><b><p><font size=6>Invalid Search Term $1</font></p></b><center>"
	exit
fi

if [ $RESULTS = 0 ]
then
	echo "<center><b><p><font size=6>There were no results for $1</font></p></b></center>"
        echo "<center>Try broadening your search criteria</center>"

        exit
fi

echo "<center><b><p><font size=6> Search results for $1: $RESULTS </font></p></b></center>"

echo "<center>Search results may be limited by docker search.  More results may be available on Docker's website<br></center>"
echo "<hr />"

OutputResults

echo "<hr />"
echo "<center>Clicking the link will take you to the associated docker page.</center>"
echo ""
echo "<center>Copy the link address, close the window and paste it into the \"Convert\" text box to convert the Docker File to an XML template for use in unRAID</center>"
echo ""

echo "<div style=\"text-align: right; direction: ltr; margin-left: 1em;\"><img src=/plugins/docker_search/images/Chode_300.gif></div>"

