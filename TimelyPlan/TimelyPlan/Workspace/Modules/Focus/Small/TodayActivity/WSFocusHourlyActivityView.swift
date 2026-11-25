//
//  WSFocusHourlyActivityView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

/// 带时间刻度的每小时活动视图。
///
/// 在 `FocusHourlyActivityView` 的基础上，用底部内边距为时间刻度预留空间，
/// 柱线的绘制逻辑完全复用父类，刻度文案直接在视图内绘制。
class WSFocusHourlyActivityView: FocusHourlyActivityView {
    
    /// 时间刻度文案，按下标均匀分布，首尾分别贴齐左右两侧
    var axisTitles: [String] = ["00:00", "12:00", "24:00"] {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    /// 刻度字体
    var axisFont: UIFont = .systemFont(ofSize: 10.0, weight: .medium) {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    /// 刻度颜色
    var axisColor: UIColor = .tertiaryLabel {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 柱线与刻度的间距
    var axisSpacing: CGFloat = 4.0 {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isOpaque = false
        self.contentMode = .redraw
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fittedSize = super.sizeThatFits(size)
        return CGSize(width: fittedSize.width, height: fittedSize.height + axisHeight)
    }
    
    override func layoutSubviews() {
        /// 底部留给时间刻度，父类按缩小后的区域绘制柱线
        padding.bottom = axisHeight
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard !axisTitles.isEmpty else {
            return
        }
        
        let barsFrame = layoutFrame()
        guard barsFrame.width > 0.0 else {
            return
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: axisFont,
            .foregroundColor: axisColor
        ]
        
        let count = axisTitles.count
        let step = count > 1 ? barsFrame.width / CGFloat(count - 1) : 0.0
        let labelY = barsFrame.maxY + axisSpacing
        
        for (index, value) in axisTitles.enumerated() {
            let title = value as NSString
            let titleSize = title.size(withAttributes: attributes)
            let centerX = barsFrame.minX + step * CGFloat(index)
            
            /// 首尾刻度贴齐两侧，中间刻度居中
            let x = min(max(centerX - titleSize.width / 2.0, barsFrame.minX),
                        barsFrame.maxX - titleSize.width)
            title.draw(at: CGPoint(x: x, y: labelY), withAttributes: attributes)
        }
    }
    
    /// 刻度区域高度
    private var axisHeight: CGFloat {
        guard !axisTitles.isEmpty else {
            return 0.0
        }
        
        return ceil(axisFont.lineHeight) + axisSpacing
    }
}
