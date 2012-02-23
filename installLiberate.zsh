#!/bin/zsh
#
# run this script from the git directory: sudo installLiberate.zsh

mkdir /usr/local
mkdir /usr/local/lib
/bin/cp	liberate-fileserver.dylib /usr/local/lib/

backupname=`date +'backup.%Y.%M.%d-%H:%M:%S'`
perl -i"$backupname" -pe 's#^<dict>$#<dict><key>EnvironmentVariables</key><dict>\n<key>DYLD_INSERT_LIBRARIES</key><string>/usr/local/lib/liberate-fileserver.dylib</string></dict>#;' /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist


