//
//  PaintMixer.hpp
//  Dropper
//
//  Created by Ryan on 1/4/25.
//

#pragma once
#include <vector>
#include <string>

struct PaintColor {
    std::string name;
    uint8_t r, g, b;
    
    PaintColor(const std::string& n, uint8_t red, uint8_t green, uint8_t blue)
        : name(n), r(red), g(green), b(blue) {}
};

struct MixingRatio {
    std::string paintName;
    float ratio;  // 0.0 to 1.0
    
    MixingRatio(const std::string& name, float r)
        : paintName(name), ratio(r) {}
};

class PaintMixer {
public:
    PaintMixer();
    
    std::vector<MixingRatio> rgbToPaintMix(uint8_t r, uint8_t g, uint8_t b) const;
    
private:
    std::vector<PaintColor> basePaints;
    
    float calculateColorDistance(uint8_t r1, uint8_t g1, uint8_t b1,
                               uint8_t r2, uint8_t g2, uint8_t b2) const;
    std::vector<MixingRatio> findNearestPaintMix(uint8_t r, uint8_t g, uint8_t b) const;
};

