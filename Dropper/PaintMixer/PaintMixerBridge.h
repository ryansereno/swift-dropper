//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Foundation/Foundation.h>

@interface PaintMixResult : NSObject
@property (nonatomic, strong) NSString *paintName;
@property (nonatomic, assign) float ratio;
@end

@interface PaintMixerBridge : NSObject

- (instancetype)init;
- (NSArray<PaintMixResult *> *)getPaintMixForColor:(uint8_t)r g:(uint8_t)g b:(uint8_t)b;

@end

