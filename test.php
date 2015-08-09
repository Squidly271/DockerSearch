#!/usr/bin/php
<?php
exec("wget https://hub.docker.com/r/aptalca/docker-duckdns/~/dockerfile/ -O /tmp/GitHub/temp");

$mystring = file_get_contents("/tmp/GitHub/temp");
$thisstring = strstr($mystring,'"dockerfile":"');
$thisstring = explode("}",$thisstring);
$thisstring = explode(":",$thisstring[0]);
unset($thisstring[0]);
$teststring = implode(":",$thisstring);
echo $teststring;

?>

