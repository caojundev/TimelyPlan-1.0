//
//  HabitReportChartRender.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/18.
//

import Foundation

class HabitReportChartRender {

    let date: Date
    
    let firstWeekday: Weekday
    
    let periodTask: HabitPeriodTask
    
    var itemMargin: CGFloat = 5.0
    
    var lineSpacing: CGFloat = 5.0
    
    var itemSize: CGSize = .size(5)
    
    private(set) var dates: [Date] = []
    
    init(date: Date, firstWeekday: Weekday, periodTask: HabitPeriodTask) {
        self.periodTask = periodTask
        self.date = date
        self.firstWeekday = firstWeekday
        self.dates = self.datesOfThisRange()
    }

    // MARK: - 子类重写
    func datesOfThisRange() -> [Date] {
        return []
    }
    
    func canvasSize() -> CGSize {
        return .zero
    }
    
    func dayFrame(at index: Int) -> CGRect {
        return .zero
    }
    
    func shouldDrawDate(_ date: Date) -> Bool {
        return true
    }
    
    func drawDays(in context: CGContext) {
        for (index, displayDate) in self.dates.enumerated() {
            guard shouldDrawDate(displayDate) else {
                continue
            }
        
            let dayFrame = self.dayFrame(at: index)
            guard periodTask.isScheduledDate(displayDate) else {
                drawNotScheduledDay(in: dayFrame, context: context)
                continue
            }
            
            let status = periodTask.status(on: displayDate)
            switch status {
            case .notStarted, .inProgress, .completed:
                self.drawProgressDay(on: displayDate, in: dayFrame, context: context)
            case .skipped(_):
                self.drawSkippedDay(in: dayFrame, context: context)
            case .failed(_):
                self.drawFailedDay(in: dayFrame, context: context)
            }
        }
    }
    
    // MARK: - Public Methods
    func renderImage(completion: @escaping (UIImage?) -> Void) {
        let size = canvasSize()
        guard size != .zero else {
            completion(nil)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            // 创建离屏图形上下文
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            guard let context = UIGraphicsGetCurrentContext() else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                
                return
            }
            
            // 遍历每天，根据类型绘制
            self.drawDays(in: context)
            
            // 从上下文获取 UIImage
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // 切回主线程回调
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    // 绘制进度日
    func drawProgressDay(on date: Date, in rect: CGRect, context: CGContext) {
        let progress = periodTask.progress(on: date)
        let backgroundColor: UIColor
        if progress == 0.0 {
            /// 未开始
            backgroundColor = .secondarySystemFill
        } else {
            let alpha = CGFloat(clampedValue(progress, 0.2, 1.0))
            backgroundColor = periodTask.habitTask.color.withAlphaComponent(alpha)
        }
        
        self.drawRoundedRect(in: rect,
                             cornerRadius: 4.0,
                             backgroundColor: backgroundColor,
                             context: context)
    }
    
    // 绘制非计划日
    func drawNotScheduledDay(in rect: CGRect, context: CGContext) {
        if let image = resGetImage("habit_report_notScheduled_20") {
            self.drawImage(image, in: rect, context: context)
        }
    }

    // 绘制跳过日
    func drawSkippedDay(in rect: CGRect, context: CGContext) {
        if let image = resGetImage("habit_report_skipped_20") {
            let color = periodTask.habitTask.color
            self.drawImage(image, withColor: color, in: rect, context: context)
        }
    }

    // 绘制失败日
    func drawFailedDay(in rect: CGRect, context: CGContext) {
        if let image = resGetImage("habit_report_failed_20") {
            self.drawImage(image, in: rect, context: context)
        }
    }

    /// 在 CGContext 上绘制一个圆角矩形
    func drawRoundedRect(in rect: CGRect, cornerRadius: CGFloat, backgroundColor: UIColor, context: CGContext) {
        // 创建圆角路径
        let path = UIBezierPath(
            roundedRect: rect,
            cornerRadius: cornerRadius
        )
        
        // 设置填充颜色
        backgroundColor.setFill()
        
        // 填充路径
        path.fill()
    }
    
    /// 将一张 UIImage 绘制到 CGContext 的指定 rect（不改变颜色）
    func drawImage(_ image: UIImage, in rect: CGRect, context: CGContext) {
        if let cgImage = image.cgImage {
            context.draw(cgImage, in: rect)
        }
    }
    
    /// 将 image 以指定颜色、位置、大小绘制到当前 CGContext 上
    func drawImage(_ image: UIImage, withColor color: UIColor, in rect: CGRect, context: CGContext) {
        // 1. 保存当前绘图状态
        context.saveGState()
        
        // 2. 裁剪到目标区域（可选，防止溢出）
        context.clip(to: rect)
        
        // 3. 设置混合模式：用颜色乘以图像的 alpha 通道
        // 这样白色部分会被染色，透明部分保持透明
        context.setBlendMode(.normal)
        
        // 4. 设置填充颜色（实际是设置 tint color）
        color.setFill()
        
        // 5. 填充整个 rect（作为底色，但只在图像非透明区域显示）
        context.fill(rect)
        
        // 6. 设置 Alpha 掩码：用图像的 alpha 通道作为遮罩
        // 关键步骤：将图像的 alpha 作为 mask 应用到当前颜色
        if let cgImage = image.cgImage {
            // 创建一个只保留 alpha 的 mask（如果图像本身有 alpha）
            // 更简单的方式：直接用 blend mode + fill + mask
            
            // 方法 A：使用 Color Blend（推荐用于单色图标）
            context.setBlendMode(.destinationIn) // 保留目标（颜色）的 RGB，但用源（image）的 alpha
            context.draw(cgImage, in: rect)
            context.setBlendMode(.normal)
        }
        
        // 7. 恢复绘图状态
        context.restoreGState()
    }
}
