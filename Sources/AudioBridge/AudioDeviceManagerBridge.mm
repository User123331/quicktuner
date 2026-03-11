// AudioDeviceManagerBridge.mm
// Objective-C++ implementation using Core Audio HAL C API

#import "AudioDeviceManagerBridge.h"
#import <CoreAudio/CoreAudio.h>
#import <AudioToolbox/AudioToolbox.h>

#pragma mark - AudioDeviceInfo Implementation

@implementation AudioDeviceInfo

- (instancetype)initWithDeviceID:(UInt32)deviceID {
    self = [super init];
    if (self) {
        _deviceID = deviceID;
        _name = [self fetchDeviceName:deviceID] ?: @"Unknown Device";
        _uid = [self fetchDeviceUID:deviceID] ?: @"";
        _hasInput = [self deviceHasInput:deviceID];
        _hasOutput = [self deviceHasOutput:deviceID];
    }
    return self;
}

- (NSString *)fetchDeviceName:(UInt32)deviceID {
    CFStringRef name = NULL;
    UInt32 dataSize = sizeof(name);
    AudioObjectPropertyAddress propertyAddress = {
        kAudioObjectPropertyName,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMain
    };

    OSStatus status = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, NULL, &dataSize, &name);
    if (status == noErr && name != NULL) {
        NSString *result = (__bridge_transfer NSString *)name;
        return result;
    }
    return nil;
}

- (NSString *)fetchDeviceUID:(UInt32)deviceID {
    CFStringRef uid = NULL;
    UInt32 dataSize = sizeof(uid);
    AudioObjectPropertyAddress propertyAddress = {
        kAudioDevicePropertyDeviceUID,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMain
    };

    OSStatus status = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, NULL, &dataSize, &uid);
    if (status == noErr && uid != NULL) {
        NSString *result = (__bridge_transfer NSString *)uid;
        return result;
    }
    return nil;
}

- (BOOL)deviceHasInput:(UInt32)deviceID {
    AudioObjectPropertyAddress propertyAddress = {
        kAudioDevicePropertyStreamConfiguration,
        kAudioDevicePropertyScopeInput,
        kAudioObjectPropertyElementMain
    };

    UInt32 dataSize = 0;
    OSStatus status = AudioObjectGetPropertyDataSize(deviceID, &propertyAddress, 0, NULL, &dataSize);
    if (status != noErr) return NO;

    AudioBufferList *bufferList = (AudioBufferList *)malloc(dataSize);
    status = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, NULL, &dataSize, bufferList);

    BOOL hasInput = NO;
    if (status == noErr) {
        for (UInt32 i = 0; i < bufferList->mNumberBuffers; i++) {
            if (bufferList->mBuffers[i].mNumberChannels > 0) {
                hasInput = YES;
                break;
            }
        }
    }

    free(bufferList);
    return hasInput;
}

- (BOOL)deviceHasOutput:(UInt32)deviceID {
    AudioObjectPropertyAddress propertyAddress = {
        kAudioDevicePropertyStreamConfiguration,
        kAudioDevicePropertyScopeOutput,
        kAudioObjectPropertyElementMain
    };

    UInt32 dataSize = 0;
    OSStatus status = AudioObjectGetPropertyDataSize(deviceID, &propertyAddress, 0, NULL, &dataSize);
    if (status != noErr) return NO;

    AudioBufferList *bufferList = (AudioBufferList *)malloc(dataSize);
    status = AudioObjectGetPropertyData(deviceID, &propertyAddress, 0, NULL, &dataSize, bufferList);

    BOOL hasOutput = NO;
    if (status == noErr) {
        for (UInt32 i = 0; i < bufferList->mNumberBuffers; i++) {
            if (bufferList->mBuffers[i].mNumberChannels > 0) {
                hasOutput = YES;
                break;
            }
        }
    }

    free(bufferList);
    return hasOutput;
}

@end

#pragma mark - AudioDeviceManagerBridge Implementation

@implementation AudioDeviceManagerBridge

- (NSArray<AudioDeviceInfo *> *)enumerateInputDevices {
    NSMutableArray<AudioDeviceInfo *> *devices = [NSMutableArray array];

    // Get all audio devices
    AudioObjectPropertyAddress propertyAddress = {
        kAudioHardwarePropertyDevices,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMain
    };

    UInt32 dataSize = 0;
    OSStatus status = AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize);
    if (status != noErr) {
        NSLog(@"Failed to get device list size: %d", (int)status);
        return devices;
    }

    UInt32 deviceCount = dataSize / sizeof(AudioDeviceID);
    AudioDeviceID *deviceIDs = (AudioDeviceID *)malloc(dataSize);

    status = AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize, deviceIDs);
    if (status != noErr) {
        NSLog(@"Failed to get device list: %d", (int)status);
        free(deviceIDs);
        return devices;
    }

    // Filter for input devices
    for (UInt32 i = 0; i < deviceCount; i++) {
        AudioDeviceInfo *info = [[AudioDeviceInfo alloc] initWithDeviceID:deviceIDs[i]];
        if (info.hasInput) {
            [devices addObject:info];
        }
    }

    free(deviceIDs);
    return devices;
}

- (BOOL)selectInputDevice:(UInt32)deviceID error:(NSError **)error {
    AudioObjectPropertyAddress propertyAddress = {
        kAudioHardwarePropertyDefaultInputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMain
    };

    UInt32 dataSize = sizeof(AudioDeviceID);
    OSStatus status = AudioObjectSetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, dataSize, &deviceID);

    if (status != noErr) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"AudioDeviceManager"
                                         code:status
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to set default input device"}];
        }
        return NO;
    }

    return YES;
}

- (UInt32)defaultInputDeviceID {
    AudioObjectPropertyAddress propertyAddress = {
        kAudioHardwarePropertyDefaultInputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMain
    };

    AudioDeviceID deviceID = 0;
    UInt32 dataSize = sizeof(deviceID);
    OSStatus status = AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize, &deviceID);

    if (status != noErr) {
        NSLog(@"Failed to get default input device: %d", (int)status);
        return 0;
    }

    return deviceID;
}

- (nullable NSString *)nameForDevice:(UInt32)deviceID {
    AudioDeviceInfo *info = [[AudioDeviceInfo alloc] initWithDeviceID:deviceID];
    return info.name;
}

- (nullable NSString *)uidForDevice:(UInt32)deviceID {
    AudioDeviceInfo *info = [[AudioDeviceInfo alloc] initWithDeviceID:deviceID];
    return info.uid;
}

@end
