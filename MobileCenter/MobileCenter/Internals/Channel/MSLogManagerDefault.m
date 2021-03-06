/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

#import "MSChannelDefault.h"
#import "MSLogManagerDefault.h"
#import "MobileCenter+Internal.h"

static char *const MSlogsDispatchQueue = "com.microsoft.azure.mobile.mobilecenter.LogManagerQueue";

/**
 * Private declaration of the log manager.
 */
@interface MSLogManagerDefault ()

/**
 *  A boolean value set to YES if this instance is enabled or NO otherwise.
 */
@property(atomic) BOOL enabled;

@end

@implementation MSLogManagerDefault

#pragma mark - Initialization

- (instancetype)init {
  if (self = [super init]) {
    dispatch_queue_t serialQueue = dispatch_queue_create(MSlogsDispatchQueue, DISPATCH_QUEUE_SERIAL);
    _enabled = YES;
    _logsDispatchQueue = serialQueue;
    _channels = [NSMutableDictionary<NSNumber *, id<MSChannel>> new];
    _delegates = [NSHashTable weakObjectsHashTable];
    _deviceTracker = [[MSDeviceTracker alloc] init];
  }
  return self;
}

- (instancetype)initWithSender:(id<MSSender>)sender storage:(id<MSStorage>)storage {
  if (self = [self init]) {
    _sender = sender;
    _storage = storage;
  }
  return self;
}

#pragma mark - Delegate

- (void)addDelegate:(id<MSLogManagerDelegate>)delegate {
  [self.delegates addObject:delegate];
}

- (void)removeDelegate:(id<MSLogManagerDelegate>)delegate {
  [self.delegates removeObject:delegate];
}

#pragma mark - Channel Delegate
- (void)addChannelDelegate:(id<MSChannelDelegate>)channelDelegate forPriority:(MSPriority)priority {
  if (channelDelegate) {
    id<MSChannel> channel = [self channelForPriority:priority];
    [channel addDelegate:channelDelegate];
  }
}

- (void)removeChannelDelegate:(id<MSChannelDelegate>)channelDelegate forPriority:(MSPriority)priority {
  if (channelDelegate) {
    id<MSChannel> channel = [self channelForPriority:priority];
    [channel removeDelegate:channelDelegate];
  }
}

- (void)enumerateDelegatesForSelector:(SEL)selector withBlock:(void (^)(id<MSLogManagerDelegate> delegate))block {
  for (id<MSLogManagerDelegate> delegate in self.delegates) {
    if (delegate && [delegate respondsToSelector:selector]) {
      block(delegate);
    }
  }
}

#pragma mark - Process items

- (void)processLog:(id<MSLog>)log withPriority:(MSPriority)priority {

  // Notify delegates.
  [self enumerateDelegatesForSelector:@selector(onProcessingLog:withPriority:)
                            withBlock:^(id<MSLogManagerDelegate> delegate) {
                              [delegate onProcessingLog:log withPriority:priority];
                            }];

  // Get the channel.
  id<MSChannel> channel = [self channelForPriority:priority];

  // Set common log info.
  log.toffset = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
  log.device = self.deviceTracker.device;

  // Asynchroneously forward to channel by using the data dispatch queue.
  [channel enqueueItem:log];
}

#pragma mark - Helpers

- (id<MSChannel>)createChannelForPriority:(MSPriority)priority {
  MSChannelDefault *channel;
  MSChannelConfiguration *configuration = [MSChannelConfiguration configurationForPriority:priority];
  if (configuration) {
    channel = [[MSChannelDefault alloc] initWithSender:self.sender
                                               storage:self.storage
                                         configuration:configuration
                                     logsDispatchQueue:self.logsDispatchQueue];
    self.channels[@(priority)] = channel;
  }
  return channel;
}

- (id<MSChannel>)channelForPriority:(MSPriority)priority {

  // Return an existing channel or create it.
  id<MSChannel> channel = [self.channels objectForKey:@(priority)];
  return (channel) ? channel : [self createChannelForPriority:priority];
}

#pragma mark - Storage

- (void)deleteLogsForPriority:(MSPriority)priority {
  [[self channelForPriority:priority] deleteAllLogs];
}

#pragma mark - Enable / Disable

- (void)setEnabled:(BOOL)isEnabled andDeleteDataOnDisabled:(BOOL)deleteData {
  if (isEnabled != self.enabled) {
    self.enabled = isEnabled;

    // Propagate to sender.
    [self.sender setEnabled:isEnabled andDeleteDataOnDisabled:deleteData];

    // Propagate to channels.
    for (NSNumber *priority in self.channels) {
      [self.channels[priority] setEnabled:isEnabled andDeleteDataOnDisabled:NO];
    }

    // If requested, delete any remaining logs (e.g., even logs from not started services).
    if (!isEnabled && deleteData) {
      for (int priority = 0; priority < kMSPriorityCount; priority++) {
        [self deleteLogsForPriority:priority];
      }
    }
  }
}

- (void)setEnabled:(BOOL)isEnabled andDeleteDataOnDisabled:(BOOL)deleteData forPriority:(MSPriority)priority {
  [[self channelForPriority:priority] setEnabled:isEnabled andDeleteDataOnDisabled:deleteData];
}

@end
