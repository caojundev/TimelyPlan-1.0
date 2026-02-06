//
//  ChartLabelsView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/28.
//

import Foundation
import UIKit

class ChartAxisLabelsView: UIView {
    
    var axis: ChartAxis = ChartAxis() {
        didSet {
            setupLabels()
            setNeedsLayout()
        }
    }
    
    private var labels: [ChartAxisLabel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutLabels()
    }

    private func setupLabels() {
        removeViews(self.labels) /// 移除原有的标签
        var labels = [ChartAxisLabel]()
        for mark in axis.labelMarks {
            let label = ChartAxisLabel(mark: mark)
            label.adjustsFontSizeToFitWidth = true
            labels.append(label)
            addSubview(label)
        }
        
        self.labels = labels
    }
    
    private func layoutLabels() {
        for label in labels {
            label.style = axis.labelStyle
            label.frame = labelFrame(for: label.mark)
        }
    }
    
    func labelFrame(for mark: ChartAxisLabelMark) -> CGRect {
        return .zero
    }
}

class ChartYLabelsView: ChartAxisLabelsView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 5.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func labelFrame(for mark: ChartAxisLabelMark) -> CGRect {
        let layoutFrame = self.layoutFrame()
        let w = layoutFrame.width
        let h = 20.0
        let x = layoutFrame.minX
        let centerY = layoutFrame.maxY - layoutFrame.height * (mark.value - axis.range.minValue) / axis.range.length
        return CGRect(x: x, y: centerY - h / 2.0, width: w, height: h)
    }
    
    func widthThatFits(minWidth: CGFloat = 0.0,
                       maxWidth: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
        var fitWidth = 0.0
        for labelMark in axis.labelMarks {
            let labelWidth = labelMark.text?.width(with: axis.labelStyle.font) ?? 0.0
            if labelWidth > fitWidth {
                fitWidth = labelWidth
            }
        }
        
        return max(min(fitWidth + padding.horizontalLength, maxWidth), minWidth)
    }
}

class ChartXLabelsView: ChartAxisLabelsView {
    
    var labelWidth: CGFloat = 40.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(top: 5.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func labelFrame(for mark: ChartAxisLabelMark) -> CGRect {
        let range = axis.range
        let layoutFrame = self.layoutFrame()
        let midX = layoutFrame.minX + layoutFrame.width * (mark.value - range.minValue) / range.length
        return CGRect(x: midX - labelWidth / 2.0,
                      y: layoutFrame.minY,
                      width: labelWidth,
                      height: layoutFrame.height)
    }
}
