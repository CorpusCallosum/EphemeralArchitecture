#!/bin/sh
if [ $(ps ax | grep -v grep | grep "LANscapesDebug.app" | wc -l) -eq 0 ]
then
       echo "LANscalpes not running. opening..."
       open /Applications/LANscapesDebug.app
else
    echo "LANscapes running"
fi