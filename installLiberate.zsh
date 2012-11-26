#!/bin/zsh
#
# run this script from the git directory: sudo installLiberate.zsh

mkdir /usr/local
mkdir /usr/local/lib
/bin/cp	liberate-fileserver.dylib /usr/local/lib/

cp /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist.`date +'backup.%Y.%M.%d-%H:%M:%S'`
defaults write /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist  EnvironmentVariables -dict DYLD_INSERT_LIBRARIES /usr/local/lib/liberate-fileserver.dylib 
plutil -convert xml1 /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist



