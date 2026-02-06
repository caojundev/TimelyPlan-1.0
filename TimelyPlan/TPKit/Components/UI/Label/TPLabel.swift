//
//  TPLabel.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/9.
//

import Foundation
import UIKit

class TPLabel: UILabel {

    /// 是否为选中状态
    var isSelected: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 边界间距
    var edgeInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        rect = rect.inset(by: edgeInsets)
        return rect
    }

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: edgeInsets)
        super.drawText(in: insetRect)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let boundingSize = CGSize(width: size.width - edgeInsets.horizontalLength,
                                  height: size.height - edgeInsets.verticalLength)
        let fitSize = super.sizeThatFits(boundingSize)
        let width = fitSize.width + 2 * edgeInsets.horizontalLength
        let height = fitSize.height + 2 * edgeInsets.verticalLength
        return CGSize(width: width, height: height)
    }
}

extension TPLabel {
    
    /// 应用配置（样式 + 内容）
    func updateConfig(_ config: TPLabelConfig) {
        self.alpha = config.alpha
        self.font = config.font
        self.numberOfLines = config.numberOfLines
        self.textAlignment = config.textAlignment
        self.lineBreakMode = config.lineBreakMode
        self.adjustsFontSizeToFitWidth = config.adjustsFontSizeToFitWidth
        
        /// 根据状态获取当前文本颜色
        var textColor: UIColor?
        if isHighlighted {
            textColor = config.highlightedTextColor
        } else if isSelected {
            textColor = config.selectedTextColor
        }
        
        if textColor == nil {
            textColor = config.textColor
        }
        
        self.textColor = textColor
    }
    
    /// 仅更新内容（保留原有样式）
    func updateContent(_ content: TPLabelContent?) {
        if let attributedText = content?.attributedText {
            self.attributed.text = attributedText
        } else {
            self.text = content?.text
        }
    }
}
