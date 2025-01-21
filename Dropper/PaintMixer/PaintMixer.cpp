#include "PaintMixer.hpp"
#include <cmath>
// #include <algorithm>

PaintMixer::PaintMixer() {
    basePaints = {
        PaintColor("Titanium White", 255, 255, 255),
        PaintColor("Cadmium Red", 227, 0, 34),
        PaintColor("Ultramarine Blue", 63, 0, 255),
        PaintColor("Cadmium Yellow", 255, 227, 0),
        PaintColor("Burnt Umber", 101, 67, 33)
    };
}

float PaintMixer::calculateColorDistance(uint8_t r1, uint8_t g1, uint8_t b1,
                                       uint8_t r2, uint8_t g2, uint8_t b2) const {
    float dr = r1 - r2;
    float dg = g1 - g2;
    float db = b1 - b2;
    return std::sqrt(dr*dr + dg*dg + db*db);
}

std::vector<MixingRatio> PaintMixer::findNearestPaintMix(uint8_t r, uint8_t g, uint8_t b) const {
    std::vector<std::pair<float, const PaintColor*>> distances;
    
    for (const auto& paint : basePaints) {
        float distance = calculateColorDistance(r, g, b, paint.r, paint.g, paint.b);
        distances.push_back({distance, &paint});
    }
    
    float totalWeight = 0.0f;
    std::vector<float> weights;
    
    for (const auto& [distance, paint] : distances) {
        float weight = 1.0f / (distance + 0.1f);
        weights.push_back(weight);
        totalWeight += weight;
    }
    
    std::vector<MixingRatio> mix;
    for (size_t i = 0; i < basePaints.size(); i++) {
        float ratio = weights[i] / totalWeight;
        mix.push_back(MixingRatio(distances[i].second->name, ratio));
    }
    
    return mix;
}

std::vector<MixingRatio> PaintMixer::rgbToPaintMix(uint8_t r, uint8_t g, uint8_t b) const {
    return findNearestPaintMix(r, g, b);
}
