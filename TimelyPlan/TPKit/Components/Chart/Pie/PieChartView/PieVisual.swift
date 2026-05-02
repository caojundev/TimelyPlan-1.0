//
//  PieVisual.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/11.
//

import UIKit

/// 填充饼状图用数据
struct PieSlice: Equatable {
    
    /// 标题
    var title: String?
    
    /// 详细描述
    var detail: String?
    
    /// 百分比,取值0...1
    var percent: Double
    
    /// 额外绑定数据
    var addtional: Any?
    
    init(title: String?, detail: String?, percent: Double, addtional: Any? = nil) {
        self.title = title
        self.detail = detail
        self.percent = percent
        self.addtional = addtional
    }
    
    /// 详细描述和百分比组合文本
    var detailPercentCombinedString: String {
        var strings = [String]()
        if let detail = detail {
            strings.append(detail)
        }
        
        let percentageString = Float(percent).percentageString(decimalPlaces: 1)
        strings.append(percentageString)
        return strings.joined(separator: " • ")
    }
    
    static func == (lhs: PieSlice, rhs: PieSlice) -> Bool {
        return lhs.title == rhs.title &&
                lhs.detail == rhs.detail &&
                lhs.percent == rhs.percent
    }
}

/// 百分占比 转化为 弧度(弧度制)
struct PieSliceAngle: Equatable {
    
    var index: Int
    
    /// 切片
    var slice: PieSlice
    
    /// 起始百分比
    var percentStart: Double
    
    /// 占比长度
    var percentLength: Double
    
    /// 起始角(弧度)
    var startAngle: CGFloat {
        return CGFloat.pi * 2 * CGFloat(percentStart) - CGFloat.pi / 2
    }
    
    /// 结束角(弧度)
    var endAngle: CGFloat {
        return CGFloat.pi * 2 * CGFloat(percentStart + percentLength) - CGFloat.pi / 2
    }
    
    /// 给定长度 算出中点延长线 方向，偏移量
    func getTranslation(newRadius: CGFloat) -> CGSize {
        // 算出度数 = (总度数 - 起始度数) / 2 + 起始度数
        let targetAngle = startAngle + (endAngle - startAngle) / 2
        let xPos = cos(targetAngle) * newRadius
        let yPos = sin(targetAngle) * newRadius
        return CGSize(width: xPos, height: yPos)
    }
    
}

/// 填充饼状图用 视觉效果
/// 填充饼状图用 视觉效果
class PieVisual {
    
    private(set) var slices: [PieSlice]?

    var colors = [#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.7960784314, green: 0.8705882353, blue: 0.2980392157, alpha: 1), #colorLiteral(red: 0.9450980392, green: 0.6705882353, blue: 0.06666666667, alpha: 1), #colorLiteral(red: 0.2392156863, green: 0.8431372549, blue: 1, alpha: 1), #colorLiteral(red: 0.9490196078, green: 0.831372549, blue: 0.05490196078, alpha: 1), #colorLiteral(red: 1, green: 0.4392156863, blue: 0.2392156863, alpha: 1)]
    
    var angles: [PieSliceAngle] = []
    
    /// 总百分比
    var totalPercent: Double = 0
    
    /// 实际显示的切片数量（包含 Others）
    private(set) var displayCount: Int = 0
    
    init(slices: [PieSlice],
         colors: [UIColor]? = nil,
         maxDisplayCount: Int? = 9,
         othersSliceProvider:(([PieSlice]) -> PieSlice)? = nil) {
        self.slices = slices
        
        if let colors = colors, colors.count > 0 {
            self.colors = colors
        }
        
        // 如果没有设置最大显示数量或切片数量不超过限制，直接使用所有切片
        guard let maxCount = maxDisplayCount, maxCount > 0 &&
                slices.count > maxCount else {
            // 不需要合并，直接使用所有数据
            self.setupAngles(with: slices)
            self.displayCount = slices.count
            return
        }
        
        // 需要合并超出限制的切片到 Others
        var displaySlices = Array(slices.prefix(maxCount))
        let othersSlices = Array(slices.suffix(from: maxCount))
        
        var othersSlice: PieSlice
        if let othersSliceProvider = othersSliceProvider {
            othersSlice = othersSliceProvider(othersSlices)
        } else {
            // 计算 Others 的总百分比
            let othersTotalPercent = othersSlices.reduce(0.0) { $0 + $1.percent }
            othersSlice = PieSlice(title: resGetString("Others"),
                                   detail: nil,
                                   percent: othersTotalPercent)
        }
        
        displaySlices.append(othersSlice)
        
        
    
        // 使用合并后的数据设置角度
        self.slices = displaySlices
        self.setupAngles(with: displaySlices)
        self.displayCount = displaySlices.count
    }
    
    /// 设置角度数据
    private func setupAngles(with slices: [PieSlice]) {
        var start: Double = 0
        angles = [PieSliceAngle]()
        totalPercent = 0
        
        for index in 0..<slices.count {
            let slice = slices[index]
            
            start = totalPercent
            totalPercent += slice.percent
            
            let angle = PieSliceAngle(index: index,
                                      slice: slice,
                                      percentStart: start,
                                      percentLength: slice.percent)
            angles.append(angle)
        }
    }
    
    /// 获取索引处的颜色
    func color(of index: Int) -> UIColor {
        let count = colors.count
        return colors[index % count]
    }
    
    /// 获取需要绘制切片角
    func drawAngles() -> [PieSliceAngle] {
        var results = [PieSliceAngle]()
        var percentLength: CGFloat?
        for angle in angles {
            if let value = percentLength, value + angle.percentLength / 2.0 < 0.1 {
                /// 小于最小百分比
                percentLength = value + angle.percentLength
                continue
            }
            
            percentLength = angle.percentLength / 2.0
            results.append(angle)
        }
        
        return results
    }
}

extension Array where Element == PieSlice {
    
    /// 数组中切片总占比
    var totalPercent: Double {
        return self.reduce(0.0) { $0 + $1.percent }
    }
    
    func totalAddtionalCount<T: Numeric>() -> T {
        var totalCount: T = 0
        for slice in self {
            let count = slice.addtional as? T ?? 0
            totalCount += count
        }
        
        return totalCount
    }
}
