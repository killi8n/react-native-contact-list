#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ContactList, NSObject)

RCT_EXTERN_METHOD(getContactList: (RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(checkPermission: (RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(requestPermission: (RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock)reject)


@end
