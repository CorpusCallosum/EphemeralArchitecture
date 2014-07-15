#!/bin/sh
if [ $(ps ax | grep -v grep | grep "LANscapesDebug.app" | wc -l) -eq 0 ]
then
echo "landscapes not running. opening…"
open /OpenFrameworks/of_v0.8.0_osx_release/apps/LANscapes/lanscapes_sound/bin/LANscapesDebug.app
else
echo "LANscapes running"
fi