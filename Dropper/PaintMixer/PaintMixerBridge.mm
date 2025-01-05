//
//  PaintMixerBridge.m
//  Dropper
//
//  Created by Ryan on 1/4/25.
//

#import "PaintMixerBridge.h"
#include "PaintMixer.hpp"

@implementation PaintMixResult
@end

@implementation PaintMixerBridge {
    PaintMixer *_mixer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mixer = new PaintMixer();
    }
    return self;
}

- (void)dealloc {
    delete _mixer;
}

- (NSArray<PaintMixResult *> *)getPaintMixForColor:(uint8_t)r g:(uint8_t)g b:(uint8_t)b {
    std::vector<MixingRatio> result = _mixer->rgbToPaintMix(r, g, b);
    
    //printf("C++ returned %lu mixing ratios\n", result.size());
    
    NSMutableArray<PaintMixResult *> *mixResults = [NSMutableArray array];
    
    for (const auto& ratio : result) {
        PaintMixResult *mixResult = [[PaintMixResult alloc] init];
        mixResult.paintName = [NSString stringWithUTF8String:ratio.paintName.c_str()];
        mixResult.ratio = ratio.ratio;
        [mixResults addObject:mixResult];
    }
    
    return mixResults;
}
@end
