#!/bin/bash

DOCKER=$1

if ! echo $DOCKER | grep "registry.hub.docker.com"
then
	echo "$DOCKER is not a valid entry"
	exit 1
fi

echo "<b>Finding the correct path"
echo ""

# Figure out what path was actually passed to us

LAST=$(dirname $DOCKER)
NEXTLAST=$(dirname $LAST)
THIRDLAST=$(dirname $NEXTLAST)
FOURTHLAST=$(dirname $THIRDLAST)
FIFTHLAST=$(dirname $FOURTHLAST)

echo "$DOCKER"

until [ "$FIFTHLAST" == "." ];
do
	DOCKER="$LAST"
	LAST=$(dirname $DOCKER)
	NEXTLAST=$(dirname $LAST)
	THIRDLAST=$(dirname $NEXTLAST)
	FOURTHLAST=$(dirname $THIRDLAST)
	FIFTHLAST=$(dirname $FOURTHLAST)

	if [ $? -ne 0 ]
	then
		echo ""
		echo "<strong>Not a valid Docker URL<strong>"
		exit 1
	fi


	echo "$DOCKER"
done

echo ""

# Handle the condition if the path ends in /

ENDINGOFFILE="dockerfile/raw"

if [ "$(echo "${DOCKER: -1}")" == "/" ]
then
        DOCKERFILE="$DOCKER$ENDINGOFFILE"
else
        DOCKERFILE="$DOCKER/$ENDINGOFFILE"
fi


echo "<b>Corrected path is $DOCKERFILE"
echo ""
if [[ "$DOCKERFILE" == "https://registry.hub.docker.com/_/"* ]]
then
	echo ""
        echo "<b>Official Status:    Official"
	/usr/local/emhttp/plugins/docker_search/scripts/official.sh $DOCKERFILE
        exit
fi

echo "<hr />"
echo "<b>Downloading $DOCKERFILE"
echo ""


if ! wget $DOCKERFILE -O /tmp/dockerfile
then
	echo ""
	echo ""
	echo "<b>Could not download the dockerfile"
	echo ""
	echo "<b>$DOCKERFILE"
	echo ""
	echo "<b>Bad URL?"
	exit 1
fi

echo "<b>Downloaded"
echo "<hr />"

DOCKERFILENAME="$(basename $(dirname "${DOCKER}"))-$(basename ${DOCKER})"

REGISTRY=$(echo "$DOCKERFILE" | sed -e "s/\/[^\/]*$//" | sed -e "s/\/[^\/]*$//")
REPOSITORY="$(echo "$REGISTRY" | grep -oP '(?<=https:\/\/registry.hub.docker.com\/u\/)\w+')"

DOCKERNAME=$(basename "$REGISTRY")

OUTPUT="/tmp/$DOCKERNAME"

echo "Docker Name:        <b>$DOCKERNAME"
echo "Docker Registry:    <b>$REGISTRY"
echo "Docker Repostitory: <b>$REPOSITORY"
echo "Template Filename:  <b>$DOCKERFILENAME"
if $(echo "$DOCKERFILE" | grep "https://registry.hub.docker.com/_/" )
then
	echo "Official Status:    <b>Official"
	echo ""
	echo "Offical containers are not currently supported"
	echo "exiting"
	exit
else
	echo "Official Status:    <b>Unofficial"
fi

echo "<hr />"


 
# Remove commented out lines from the docker file

cat "/tmp/dockerfile" | while read LINE
do
	FIRSTCHAR="$(echo "$LINE" | sed 's/^[\t ]*//g' | cut -c 1-1 )"

	if [ "$FIRSTCHAR" == "#" ]
	then
		continue
	else
		echo "$LINE" >> /tmp/dockerfile1
	fi
done

mv /tmp/dockerfile1 /tmp/dockerfile

# Get the exposed ports.  Other ports are assumed to be TCP ** Not specified by docker file **

PORTLIST="$(cat /tmp/dockerfile | grep "EXPOSE" )"

MYPORTS="$(echo "$PORTLIST" | sed 's/EXPOSE//' | sed -e 's/ / EXPOSE /g' | sed -e 's/ EXPOSE/\nEXPOSE/g' | sed 's/EXPOSE//')"

TCPPORTS="$(echo "$MYPORTS" | egrep -i "/tcp" | sed 's/^.//' | sed 's/.\{4\}$//')"
UDPPORTS="$(echo "$MYPORTS" | egrep -i "/udp" | sed 's/^.//' | sed 's/.\{4\}$//')"
OTHERPORTS="$(echo "$MYPORTS" | egrep -v -i "/tcp" | egrep -v -i "/udp" |sed 's/^.//')"
NUMPORTS=0

# Get the container's Volumes

VOLUMELIST="$(cat /tmp/dockerfile | egrep "VOLUME" | sed 's/VOLUME//g')"

# Replace messed characters []," with spaces since there are multiple ways of handling VOLUMES

VOLUMELIST="$(echo "$VOLUMELIST" | sed 's/\[/ /g' | sed 's/\]/ /g' | sed 's/\,/ /g' | sed 's/\"/ /g')"


echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" > $OUTPUT
echo "<Container>" >> $OUTPUT
echo "	<Name>$DOCKERNAME</Name>" >> $OUTPUT
echo "	<Description>Converted XML File from $DOCKERFILE.[br][br]Converted by Docker2XML.[br][br][span style=\'color: #E80000;\']Double check the entries via the Advanced View button.[br][br]You will need to manually add any required environment variables.[/span]" >> $OUTPUT
echo "	</Description>" >> $OUTPUT
echo "	<Registry>$REGISTRY</Registry>" >> $OUTPUT
echo "	<Repository>$REPOSITORY/$DOCKERNAME</Repository>" >> $OUTPUT
echo "	<BindTime>true</BindTime>" >> $OUTPUT
echo "	<Privileged>false</Privileged>" >> $OUTPUT
echo "	<Environment/>" >> $OUTPUT
echo "	<Networking>" >> $OUTPUT
echo "		<Mode>bridge</Mode>" >> $OUTPUT
echo "		<Publish>" >> $OUTPUT

for PORT in $TCPPORTS
do
	echo "		<Port>" >> $OUTPUT
	echo "			<HostPort>$PORT</HostPort>" >> $OUTPUT
	echo "			<ContainerPort>$PORT</ContainerPort>" >> $OUTPUT
	echo "			<Protocol>tcp</Protocol>" >> $OUTPUT
	echo "		</Port>" >> $OUTPUT

	echo "Added TCP Port: <b>$PORT"

	NUMPORTS=$((NUMPORTS+1))
done

for PORT in $UDPPORTS
do
        echo "          <Port>" >> $OUTPUT
        echo "                  <HostPort>$PORT</HostPort>" >> $OUTPUT
        echo "                  <ContainerPort>$PORT</ContainerPort>" >> $OUTPUT
        echo "                  <Protocol>udp</Protocol>" >> $OUTPUT
        echo "          </Port>" >> $OUTPUT

	NUMPORTS=$((NUMPORTS+1))

	echo "Added UDP Port: <b>$PORT"
done

for PORT in $OTHERPORTS
do
        echo "          <Port>" >> $OUTPUT
        echo "                  <HostPort>$PORT</HostPort>" >> $OUTPUT
        echo "                  <ContainerPort>$PORT</ContainerPort>" >> $OUTPUT
        echo "                  <Protocol>tcp</Protocol>" >> $OUTPUT
        echo "          </Port>" >> $OUTPUT

	NUMPORTS=$((NUMPORTS+1))

	echo "Added TCP Port: <b>$PORT"
done
echo "		</Publish>" >> $OUTPUT
echo "	</Networking>" >> $OUTPUT
echo "	<Data>" >> $OUTPUT

echo ""

for VOLUME in $VOLUMELIST
do
	echo "	<Volume>" >> $OUTPUT
	echo "		<HostDir>Change to suitable unRaid directory</HostDir>" >> $OUTPUT
	echo "		<ContainerDir>$VOLUME</ContainerDir>" >> $OUTPUT
	echo "		<Mode>rw</Mode>" >> $OUTPUT
	echo "	</Volume>" >> $OUTPUT

	echo "Added Container Volume: <b>$VOLUME"
done

echo "	</Data>" >> $OUTPUT

echo ""

if [ $NUMPORTS -eq 1 ]
then
	echo "	<WebUI>http://[IP]:[PORT:$PORT]</WebUI>" >> $OUTPUT

	echo "Added WebUI port: <b>$PORT"
else
	echo "<b>Could not accurately determine WebUI Port"
fi

	echo "	<Icon>https://raw.githubusercontent.com/Squidly271/DockerSearch/master/docker.png</Icon>" >> $OUTPUT
	echo "	<Banner>https://raw.githubusercontent.com/Squidly271/DockerSearch/master/docker_banner.png</Banner>" >> $OUTPUT

echo "</Container>" >> $OUTPUT

CONVERTED="/boot/config/plugins/dockerMan/templates-user/docker2XML-$DOCKERFILENAME.xml"

if [ ! -d /boot/config/plugins/dockerMan/templates-user/Docker2XML/ ]
then
	mkdir -p /boot/config/plugins/dockerMan/templates-user/Docker2XML/
fi

echo ""
echo "<hr />"
mv "$OUTPUT" "$CONVERTED"
echo "<b>Converted file now available at $CONVERTED"
echo ""
echo "<b>After loading the template, make sure you assign the Host Volume Paths and double-check the Host Port Assignments"
echo ""
rm /tmp/dockerfile



