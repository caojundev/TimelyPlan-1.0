//
//  UITextView+LineFrames.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/30.
//

import Foundation
import UIKit

extension UITextView {
    
    /// 获取所有行的frame数组
    func lineFrames() -> [CGRect] {
        var lineFrames = [CGRect]()
        
        guard let text = self.text, !text.isEmpty else {
            return lineFrames
        }
        
        let layoutManager = self.layoutManager
        let textContainer = self.textContainer
        
        // 计算并填充布局
        layoutManager.ensureLayout(for: textContainer)
    
        // 遍历每个行片段，并计算其frame
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (_, usedRect, _, range, _) in
            if range.location == NSNotFound || range.length == 0 {
                return
            }
            
            var lineRect = usedRect
            if lineRect != .zero {
                lineRect.origin = CGPoint(x: lineRect.minX + self.textContainerInset.left, y: lineRect.minY + self.textContainerInset.top)
                lineFrames.append(lineRect)
            }
        }
        
        return lineFrames
    }
}
