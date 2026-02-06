
import UIKit

/// 填充饼状图用数据
struct PieSlice: Equatable {
    
    /// 标题
    var title: String?
    
    /// 详细描述
    var detail: String?
    
    /// 百分比,取值0...1
    var percent: Double
    
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
class PieVisual {
    
    var slices: [PieSlice]?
    
    var colors = [#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.7960784314, green: 0.8705882353, blue: 0.2980392157, alpha: 1), #colorLiteral(red: 0.9450980392, green: 0.6705882353, blue: 0.06666666667, alpha: 1), #colorLiteral(red: 0.2392156863, green: 0.8431372549, blue: 1, alpha: 1), #colorLiteral(red: 0.9490196078, green: 0.831372549, blue: 0.05490196078, alpha: 1), #colorLiteral(red: 1, green: 0.4392156863, blue: 0.2392156863, alpha: 1)]
    
    var angles: [PieSliceAngle]
    
    /// 总百分比
    var totalPercent: Double = 0
    
    init(slices: [PieSlice], colors: [UIColor]? = nil) {
        self.slices = slices
        
        var start: Double = 0
        angles = [PieSliceAngle]()
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
        
        if let colors = colors, colors.count > 0 {
            self.colors = colors
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
    
    
    static let demo: PieVisual = {
        let colors = [#colorLiteral(red: 0.7960784314, green: 0.8705882353, blue: 0.2980392157, alpha: 1), #colorLiteral(red: 0.9450980392, green: 0.6705882353, blue: 0.06666666667, alpha: 1), #colorLiteral(red: 0.2392156863, green: 0.8431372549, blue: 1, alpha: 1), #colorLiteral(red: 0.9490196078, green: 0.831372549, blue: 0.05490196078, alpha: 1), #colorLiteral(red: 1, green: 0.4392156863, blue: 0.2392156863, alpha: 1),
                      #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)]
        let slices = [
            PieSlice(title: "A级", detail: "5%", percent: 0.05),
            PieSlice(title: "B级", detail: "15%", percent: 0.05),
            PieSlice(title: "C级", detail: "20%", percent: 0.1),
            PieSlice(title: "J级", detail: "20%", percent: 0.2),
            PieSlice(title: "K级", detail: "20%", percent: 0.2),
            PieSlice(title: "L级", detail: "20%", percent: 0.1),
            PieSlice(title: "D级", detail: "20%", percent: 0.1),
            PieSlice(title: "E级", detail: "10%", percent: 0.1),
            PieSlice(title: "S级", detail: "30%", percent: 0.1)
        ]
        
        return PieVisual.init(slices: slices, colors: colors)
    }()
    
}
