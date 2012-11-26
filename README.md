# Liberate AppleFileServer

## The Epic Disclaimer!

The included code works _just well enough_ for my purposes and hasn't been tested at all outside my set-up. Basically, if you're going to play with this you must (a) know exactly what it's doing and why it's doing it, and (b) have backups of any data it goes anywhere near. Whilst I've not experienced any negative side-effects (so far) this doesn't mean you won't and I'm not accepting any liability for anything that may go wrong.

## The background

For some reason, Apple have neutered the AppleFileServer in Lion preventing non-HFS external disk filesystems from being shared over AFP. This is exceptionally frustrating and has scuppered my plans for a ZFS based file-server backed by a pool of USB and FireWire disks. The common suggestion of copying the AppleFileServer binary from Snow Leopard into place left a bad taste in my mouth, so I wondered if there was a better way...

## The hook

This library gets injected (using the `DYLD_INJECT_LIBRARY` environment variable) into the AppleFileServer process by a tweak to the launchd configuration. Once in place, it hooks the `FSGetVolumeInfo` API call and fudges the return values to make all your volumes _look_ like they are HFS+ volumes. Specifically, the `filesystemID` field is forced to 0 and the `signature` set to a specific constant.

This is the result of numerous hours poking around at the various candidate API function calls that provide filesystem information, from inside the AppleFileSystem daemon with GDB, a test hook library and a small test ZFS pool.

I've been using the excellent [MacZFS](http://code.google.com/p/maczfs/) package. Well worth playing around with.

## Installation

You'll need to compile a .dylib shared library from the c-file, which you can do (if you have the Apple Developer Tools installed) by executing:

    gcc -dynamiclib -Wall -undefined dynamic_lookup -o liberate-fileserver.dylib liberate.m
    
This will kick out a shared library file `liberate-fileserver.dylib` that must be copied into place, pop it into `/usr/local/lib` for now.

    sudo mkdir -p /usr/local/lib
    sudo cp liberate-fileserver.dylib /usr/local/lib/

Now inject this library into the AppleFileServer daemon by adding the liberate fileserver library to the dynamic loading path of apples fileserver:

    sudo defaults write /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist  EnvironmentVariables -dict DYLD_INSERT_LIBRARIES /usr/local/lib/liberate-fileserver.dylib 
  
Once you've done this, restart the File Sharing server from within System Preferences, share your filesystem and (hopefully) it should be available to your networked machines.

Huzzah!

