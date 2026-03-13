// AudioDeviceManagerBridge.h
// Objective-C wrapper for Core Audio HAL C API

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Information about an audio device
@interface AudioDeviceInfo : NSObject

@property (nonatomic, readonly) UInt32 deviceID;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *uid;
@property (nonatomic, readonly) BOOL hasInput;
@property (nonatomic, readonly) BOOL hasOutput;

- (instancetype)initWithDeviceID:(UInt32)deviceID NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

/// Bridge between Swift and Core Audio HAL
@interface AudioDeviceManagerBridge : NSObject

/// Enumerate all available input devices
/// @return Array of devices with input capability
- (NSArray<AudioDeviceInfo *> *)enumerateInputDevices;

/// Select an input device as the default
/// @param deviceID The device ID to select
/// @param error Error pointer for failure details
/// @return YES on success, NO on failure
- (BOOL)selectInputDevice:(UInt32)deviceID error:(NSError **)error;

/// Get the current default input device ID
/// @return Device ID of default input, or 0 if none
- (UInt32)defaultInputDeviceID;

/// Get the name of a device by ID
/// @param deviceID The device ID
/// @return Device name, or nil if not found
- (nullable NSString *)nameForDevice:(UInt32)deviceID;

/// Get the UID of a device by ID
/// @param deviceID The device ID
/// @return Device UID (persistent identifier), or nil if not found
- (nullable NSString *)uidForDevice:(UInt32)deviceID;

@end

NS_ASSUME_NONNULL_END
