//
//  UILabel+LineFrames.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/16.
//

import Foundation

extension UILabel {
    
    /// 获取所有行的frame数组
    func lineFrames() -> [CGRect] {
        var lineFrames = [CGRect]()
        guard let text = self.text, !text.isEmpty else {
            return lineFrames
        }
        
        // 创建带有字体属性的attributedText
        let attributedText = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.font: self.font!
        ])
        
        // 计算最大行数
        let maxNumberOfLines = Int(bounds.height / self.font.lineHeight)

        // 创建布局管理器和文本存储
        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addLayoutManager(layoutManager)
        
        // 创建文本容器并设置其宽度为视图的宽度
        let textContainer = NSTextContainer(size: CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude))
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = maxNumberOfLines
        layoutManager.addTextContainer(textContainer)
        
        // 计算文本矩形
        let textRect = textRect(forBounds: bounds, limitedToNumberOfLines: maxNumberOfLines)
        
        // 垂直中心对齐
        let dy = (self.bounds.height - textRect.height) / 2.0

        // 遍历每个行片段，并计算其frame
        let glyphRange = NSRange(location: 0, length: layoutManager.numberOfGlyphs)
        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (_, usedRect, _, range, _) in
            if range.location == NSNotFound || range.length == 0 {
                return
            }
            
            var lineRect = usedRect
            if lineRect != .zero {
                lineRect.origin = CGPoint(x: lineRect.minX, y: lineRect.minY + dy)
                lineFrames.append(lineRect)
            }
        }
        
        return lineFrames
    }
}

