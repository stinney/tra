#!/bin/sh
title=`xl 00lib/config.xml | grep '<title>' | xmllint -xpath '*/text()' -`
echo "$0: using title '$title'"
h=00res/cat.html
cat >$h <<EOF
<html><head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
<title>$title Catalogue</title>
<link rel="stylesheet" type="text/css" href="../css/tra.css"/></head><body><h1>$title Sources</h1>
EOF
rocox -h 00lib/cat.tsv | sed 's#\([PX][0-9]\{6\}\)#<a href="https://cdli.earth/\1">\1</a>#g' >>$h
echo '</body></html>' >>$h
