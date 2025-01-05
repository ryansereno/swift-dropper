//
//  PaintMixer.cpp
//  Dropper
//
//  Created by Ryan on 1/4/25.
//

#include <stdio.h>
#include "PaintMixer.hpp"
#include <cmath>
#include <algorithm>

PaintMixer::PaintMixer() {
    // Initialize with some basic oil paint colors
    basePaints = {
        PaintColor("Titanium White", 255, 255, 255),
        PaintColor("Cadmium Yellow", 255, 227, 0),
        PaintColor("Cadmium Red", 227, 0, 34),
        PaintColor("Ultramarine Blue", 63, 0, 255),
        PaintColor("Burnt Umber", 101, 67, 33),
        PaintColor("Mars Black", 0, 0, 0)
    };
}

float PaintMixer::calculateColorDistance(uint8_t r1, uint8_t g1, uint8_t b1,
                                       uint8_t r2, uint8_t g2, uint8_t b2) const {
    // Using simple Euclidean distance for now
    // Could be improved with more sophisticated color space calculations
    float dr = r1 - r2;
    float dg = g1 - g2;
    float db = b1 - b2;
    return std::sqrt(dr*dr + dg*dg + db*db);
}

std::vector<MixingRatio> PaintMixer::findNearestPaintMix(uint8_t r, uint8_t g, uint8_t b) const {
    // This is a simplified version - in reality, you'd want a more sophisticated
    // algorithm that considers actual paint mixing behavior
    std::vector<std::pair<float, const PaintColor*>> distances;
    
    for (const auto& paint : basePaints) {
        float distance = calculateColorDistance(r, g, b, paint.r, paint.g, paint.b);
        distances.push_back({distance, &paint});
    }
    
    // Sort by distance
    std::sort(distances.begin(), distances.end());
    
    // For now, just return the two closest colors with simple ratios
    std::vector<MixingRatio> mix;
    if (distances.size() >= 2) {
        float totalDist = distances[0].first + distances[1].first;
        if (totalDist > 0) {
            float ratio1 = 1.0f - (distances[0].first / totalDist);
            float ratio2 = 1.0f - (distances[1].first / totalDist);
            
            mix.push_back(MixingRatio(distances[0].second->name, ratio1));
            mix.push_back(MixingRatio(distances[1].second->name, ratio2));
        }
    }
    
    return mix;
}

std::vector<MixingRatio> PaintMixer::rgbToPaintMix(uint8_t r, uint8_t g, uint8_t b) const {
    return findNearestPaintMix(r, g, b);
}
