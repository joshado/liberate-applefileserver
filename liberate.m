#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

struct interpose {
    void *old;
    void *new;
};

const void * out_getValue (CFDictionaryRef theDict, const void *key);
CFDictionaryRef our_DADiskCopyDescription( DADiskRef disk );

OSErr my_FSGetVolumeInfo (FSVolumeRefNum volume,
   ItemCount volumeIndex,
   FSVolumeRefNum *actualVolume,
   FSVolumeInfoBitmap whichInfo,
   FSVolumeInfo *info,
   HFSUniStr255 *volumeName,
   FSRef *rootDirectory
) {
  
  OSErr err = FSGetVolumeInfo(volume, volumeIndex, actualVolume, whichInfo, info, volumeName, rootDirectory);
  
  FILE* thelog = fopen("/tmp/output", "a");
  if(info) {
    char buffer[500];
    
    if(rootDirectory != nil) {
      FSRefMakePath( rootDirectory, buffer, 500 );
      fprintf(thelog, "       FSGetVolumeInfo %i %i %s\n", info->filesystemID, info->signature, buffer );
      if( strcmp(buffer, "/Volumes/tank") == 0 ) {
        info->filesystemID = 0;
        info->signature = 18475;
      }
      fprintf(thelog, "[after] FSGetVolumeInfo %i %i %s\n", info->filesystemID, info->signature, buffer );
      
    }
  } else {
    fprintf(thelog, "No info" );
  }
  fclose(thelog);
  
  return err;
}

void logobj( char* message, CFTypeRef obj ) {
  CFStringRef theString = CFCopyDescription( obj );
  char buffer[1024];

  CFStringGetCString( theString, buffer, 1024, kCFStringEncodingASCII );
  FILE* thelog = fopen("/tmp/output", "a");
  fprintf(thelog, "%s: %s\n", message, buffer );
  fclose(thelog);
  
  CFRelease(theString);
}

CFDictionaryRef watchDictionary = nil;

const void * my_CFDictionaryGetValue (CFDictionaryRef theDict, const void *key) {
  const void* value = CFDictionaryGetValue(theDict, key);
  // FILE* thelog = fopen("/tmp/output", "a");
  // fprintf(thelog, "GetValue %p == %p\n", theDict, watchDictionary);
  // fclose(thelog);
  return value;
}

Boolean my_CFDictionaryGetValueIfPresent (
   CFDictionaryRef theDict,
   const void *key,
   const void **value
) {
  Boolean ret = CFDictionaryGetValueIfPresent(theDict, key, value);
  
  if (theDict == watchDictionary) {

    logobj("CFDictionaryGetValueIfPresent", key);
    if( *value ) {
    } else {
      *value = CFUUIDCreate(kCFAllocatorDefault);
    }

    logobj("value = ", *value);
  }
  
  return ret;
}

void my_CFDictionaryGetKeysAndValues (CFDictionaryRef theDict,const void **keys,const void **values) {
  CFDictionaryGetKeysAndValues(theDict, keys, values);
  FILE* thelog = fopen("/tmp/output", "a");
//  fprintf(thelog, "CFDictionaryGetKeysAndValues %p == %p\n", theDict, watchDictionary);
  fclose(thelog);
}


CFDictionaryRef my_DADiskCopyDescription( DADiskRef disk ) {
  logobj("DADiskRef", disk);
  
  CFDictionaryRef dict = DADiskCopyDescription( disk );
  watchDictionary = dict;
  FILE* thelog = fopen("/tmp/output", "a");
  fprintf(thelog, "DADiskCopyDescription (%p)\n", watchDictionary);
  fclose(thelog);
  
  return dict;
}


static const struct interpose func[] __attribute__((section("__DATA, __interpose"))) = {
    { (void *) my_FSGetVolumeInfo, (void *) FSGetVolumeInfo},
//    { (void *) my_DADiskCopyDescription, (void *) DADiskCopyDescription},
    { (void *) my_CFDictionaryGetValue, (void *) CFDictionaryGetValue},
    { (void *) my_CFDictionaryGetValueIfPresent, (void *) CFDictionaryGetValueIfPresent},    
    { (void *) my_CFDictionaryGetKeysAndValues, (void *) CFDictionaryGetKeysAndValues}


};



const void * out_getValue (CFDictionaryRef theDict, const void *key) {
// /  logobj( "CFDictionaryGet", theDict );
  return CFDictionaryGetValue(theDict, key);
}



//static 

// int main(int argc, void** argv) {
//   void* handle = dlopen("/System/Library/Frameworks/DiskArbitration.framework/DiskArbitration", RTLD_NOW);
//     real_copy = 
//     
//   
//   
//   DASessionRef session;
//   DADiskRef disk;
//   
//   CFURLRef diskPath = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, CFSTR("/Volumes/tank"), kCFURLPOSIXPathStyle, false);
//   
//   session = DASessionCreate(kCFAllocatorDefault);
//   disk = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, diskPath);
//   
//   NSLog(@"Got a disk: %@ %@", disk, DADiskCopyDescription(disk));
//     
//   return 0;
// }