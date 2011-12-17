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
  
//  FILE* thelog = fopen("/tmp/output", "a");
  if(info) {
//    char buffer[500];
    
//    if(rootDirectory != nil) {
//      FSRefMakePath( rootDirectory, buffer, 500 );
//      fprintf(thelog, "       FSGetVolumeInfo %i %i %s\n", info->filesystemID, info->signature, buffer );
//        if( strcmp(buffer, "/Volumes/tank") == 0 ) {
        info->filesystemID = 0;
        info->signature = 18475;
//        }
//        fprintf(thelog, "[after] FSGetVolumeInfo %i %i %s\n", info->filesystemID, info->signature, buffer );
//      }
//    } else {
//      fprintf(thelog, "No info" );
  }
//    fclose(thelog);
  return err;
}

static const struct interpose func[] __attribute__((section("__DATA, __interpose"))) = {
    { (void *) hooked_FSGetVolumeInfo, (void *) FSGetVolumeInfo}
};

