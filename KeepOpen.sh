#!/bin/sh
if [ $(ps ax | grep -v grep | grep "LANscapes.app" | wc -l) -eq 0 ]
then
       echo "LANscalpes not running. opening..."
       open /Applications/LANscapes.app
else
    echo "LANscapes running"
fi