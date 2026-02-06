//
//  TPLabelLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/10.
//

import Foundation

class TPLabelLayout {
    
    /// 内容
    var content: TPLabelContent?
    
    /// 配置
    var config: TPLabelConfig
    
    init(content: TPLabelContent?, config: TPLabelConfig) {
        self.content = content
        self.config = config
    }
    
    /// 计算文本在给定宽度约束下的边界大小
    ///
    /// - Parameter constraintWidth: 文本的最大宽度
    /// - Returns: 文本在给定宽度约束下的边界大小
    func boundingSize(with constraintWidth: CGFloat) -> CGSize {
        let size: CGSize = .boundingSize(string: content?.value,
                                         font: config.font,
                                         constraintWidth: constraintWidth,
                                         linesCount: config.numberOfLines)
        return size
    }
    
    func sizeThatFits(size: CGSize) -> CGSize {
        var boudingSize = boundingSize(with: size.width)
        boudingSize.height = min(boudingSize.height, size.height)
        return boudingSize
    }
}
