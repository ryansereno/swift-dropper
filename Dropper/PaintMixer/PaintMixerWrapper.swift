// PaintMixerWrapper.swift

import Foundation
import UIKit

// Make PaintMix struct public
public struct PaintMix {
    let paintName: String
    let ratio: Float
}

// Make PaintMixerWrapper public
public class PaintMixerWrapper {
    private let bridge: PaintMixerBridge
    
    public init() {
        bridge = PaintMixerBridge()
    }
    
    public func getMixForColor(_ color: UIColor) -> [PaintMix] {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let results = bridge.getPaintMix(
            forColor: UInt8(r * 255),
            g: UInt8(g * 255),
            b: UInt8(b * 255)
        )
        
        // Handle optional array
        guard let mixResults = results else {
            return []
        }
 //       for result in mixResults {
 //              print("Paint Name:", result.paintName)
//                          print("Ratio:", result.ratio)
//           }// Convert PaintMixResult objects to PaintMix structs
//        print("===")
        return mixResults.map { result in
            PaintMix(
                paintName: result.paintName as String,
                ratio: result.ratio
            )
        }
    }
}
