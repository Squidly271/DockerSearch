#!/bin/bash

# Conversion program for OFFICIAL containers.

# This creates a minimal XML file for unRAID - Only enough to actually pull the container

DOCKERFILE=$(echo $1 | sed 's/.\{15\}$//' | sed 's/\/tags//g' )

CONTAINER=$(basename $DOCKERFILE)

OUTPUT="/tmp/dockerfile"

CONVERTEDFILENAME="/boot/config/plugins/dockerMan/templates-user/Docker2XML/$CONTAINER-instance.xml"

echo "<hr />"
echo "<b>Official Container Path is $DOCKERFILE</b>"
echo ""
echo "Container is $CONTAINER"



echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" > $OUTPUT
echo "<Container>" >> $OUTPUT
echo "<Name>$CONTAINER-instance</Name>" >> $OUTPUT
echo "<Description>This is a barebones template for [strong]$CONTAINER[/strong][br][br]You will need to fully populate any required Volumes, Ports, and Environment variables for this container to function [br][br]Change the Name to suit[br][br]The REPOSITORY entry [strong]MUST[/strong] remain blank[br][br]If you wish to grab a specific version, append :TAG to the ExtraParameters Field eg: mysql:5.5" >> $OUTPUT
echo "</Description>" >> $OUTPUT
echo "<Registry>$DOCKERFILE</Registry>" >> $OUTPUT
echo "<Repository>$CONTAINER</Repository>" >> $OUTPUT
echo "<BindTime>true</BindTime>" >> $OUTPUT
echo "<Privileged>false</Privileged>" >> $OUTPUT
echo "<Environment></Environment>" >> $OUTPUT
echo "<Networking>" >> $OUTPUT
echo "<Mode>bridge</Mode>" >> $OUTPUT
echo "<Publish></Publish>" >> $OUTPUT
echo "</Networking>" >> $OUTPUT
echo "<Data></Data>" >> $OUTPUT
echo "<Version></Version>" >> $OUTPUT
echo "<WebUI></WebUI>" >> $OUTPUT
echo " <Icon>https://raw.githubusercontent.com/Squidly271/DockerSearch/master/docker.png</Icon>" >> $OUTPUT
echo " <Banner>https://raw.githubusercontent.com/Squidly271/DockerSearch/master/docker_banner.png</Banner>" >> $OUTPUT
echo "</Container>" >> $OUTPUT

if [ ! -d /boot/config/plugins/dockerMan/templates-user/Docker2XML/ ]
then
        mkdir -p /boot/config/plugins/dockerMan/templates-user/Docker2XML/
fi

mv "$OUTPUT" "$CONVERTEDFILENAME"
echo "<hr />"
echo "<b>Converted file now available at $CONVERTEDFILENAME"



