#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

struct interpose {
    void *old;
    void *new;
};

OSErr hooked_FSGetVolumeInfo (FSVolumeRefNum volume,
   ItemCount volumeIndex,
   FSVolumeRefNum *actualVolume,
   FSVolumeInfoBitmap whichInfo,
   FSVolumeInfo *info,
   HFSUniStr255 *volumeName,
   FSRef *rootDirectory
) {
  OSErr err = FSGetVolumeInfo(volume, volumeIndex, actualVolume, whichInfo, info, volumeName, rootDirectory);
  
  if(info) {
        info->filesystemID = 0;
        info->signature = 18475;
  }
  return err;
}

static const struct interpose func[] __attribute__((section("__DATA, __interpose"))) = {
    { (void *) hooked_FSGetVolumeInfo, (void *) FSGetVolumeInfo}
};

