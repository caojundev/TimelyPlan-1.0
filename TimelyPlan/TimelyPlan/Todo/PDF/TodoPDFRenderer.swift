//
//  TodoPDFRenderer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/17.
//

import Foundation
import UIKit

// MARK: - 渲染层模型（渲染器只认这些）

/// 子步骤 / 子项
struct PDFSubStep {
    let title: String
    let isCompleted: Bool
    /// 可选备注，显示在标题下方小字
    let note: String?
    /// 可选进度（0.0 - 1.0）
    let progress: Double?
    /// 可选的子步骤（支持多级嵌套）
    let subSteps: [PDFSubStep]?

    init(title: String, isCompleted: Bool = false, note: String? = nil, progress: Double? = nil, subSteps: [PDFSubStep]? = nil) {
        self.title = title
        self.isCompleted = isCompleted
        self.note = note
        self.progress = progress
        self.subSteps = subSteps
    }
}

/// 任务优先级（可选，不设置则不显示标记）
enum PDFPriority {
    case low, medium, high

    var color: UIColor {
        switch self {
        case .low:    return .systemBlue
        case .medium: return .systemOrange
        case .high:   return .systemRed
        }
    }
}

/// PDF 任务项 —— 渲染器的唯一输入模型
struct PDFTask {
    let title: String
    let isCompleted: Bool
    let subSteps: [PDFSubStep]
    let priority: PDFPriority?
    /// 可选标签，显示在标题右侧
    let tag: String?
    /// 可选进度（0.0 - 1.0），如果设置则显示圆环进度条
    let progress: Double?
    /// 可选备注，显示在标题下方小字
    let note: String?

    init(
        title: String,
        isCompleted: Bool = false,
        subSteps: [PDFSubStep] = [],
        priority: PDFPriority? = nil,
        tag: String? = nil,
        progress: Double? = nil,
        note: String? = nil
    ) {
        self.title = title
        self.isCompleted = isCompleted
        self.subSteps = subSteps
        self.priority = priority
        self.tag = tag
        self.progress = progress
        self.note = note
    }
}

/// PDF 分组
struct PDFGroup {
    let title: String
    let tasks: [PDFTask]
    
    init(title: String, tasks: [PDFTask]) {
        self.title = title
        self.tasks = tasks
    }
}

/// PDF 清单
struct PDFList {
    let title: String
    let groups: [PDFGroup]
    
    init(title: String, groups: [PDFGroup]) {
        self.title = title
        self.groups = groups
    }
}

// MARK: - 转换协议（核心：任何模型实现它就能打印）

/// 单个任务可转换协议
protocol PDFTaskConvertible {
    func asPDFTask() -> PDFTask
}

/// 分组可转换协议
protocol PDFGroupConvertible {
    var pdfGroupTitle: String { get }
    func asPDFTasks() -> [PDFTask]
}

/// 整个清单可转换协议
protocol PDFListConvertible {
    var pdfTitle: String { get }
    func asPDFGroups() -> [PDFGroup]
}

// MARK: - PDF 渲染器
final class TodoPDFRenderer {

    struct Config {
        var pageSize = CGSize(width: 595.2, height: 841.8) // A4
        var pageMargins = UIEdgeInsets(top: 48, left: 56, bottom: 48, right: 56)
        var titleFont: UIFont = .systemFont(ofSize: 26, weight: .bold)
        var groupTitleFont: UIFont = .systemFont(ofSize: 18, weight: .semibold)
        var taskFont: UIFont = .systemFont(ofSize: 15, weight: .regular)
        var subStepFont: UIFont = .systemFont(ofSize: 13, weight: .regular)
        var noteFont: UIFont = .systemFont(ofSize: 11, weight: .regular)
        var footerFont: UIFont = .systemFont(ofSize: 9, weight: .regular)
        var checkboxDiameter: CGFloat = 16
        var checkboxCornerRadius: CGFloat = 4
        var checkboxTextGap: CGFloat = 10
        var checkboxBorderWidth: CGFloat = 1.8
        var subStepIndent: CGFloat = 30
        var titleBottomGap: CGFloat = 14
        var dividerWidth: CGFloat = 1.2
        var taskRowHeight: CGFloat = 28
        var subStepRowHeight: CGFloat = 22
        var noteRowHeight: CGFloat = 18
        var taskBlockGap: CGFloat = 6
        var groupTitleTopGap: CGFloat = 20
        var groupTitleBottomGap: CGFloat = 10
        var footerBrandText = "Printed with TimelyPlan"
        var exportDate: Date = Date()
        /// 是否显示优先级圆点
        var showsPriority = true
        /// 是否显示标签
        var showsTag = true
        /// 进度环线宽
        var progressRingWidth: CGFloat = 2.5
        /// 进度环直径（稍大于普通复选框）
        var progressRingDiameter: CGFloat = 18
        /// 主任务 note 与主任务底部间距
        var taskNoteTopGap: CGFloat = 8.0
    }

    private let listTitle: String
    private let groups: [PDFGroup]
    private let config: Config

    /// 便捷初始化：传整个可转换清单
    convenience init(list: PDFListConvertible, config: Config = Config()) {
        self.init(title: list.pdfTitle, groups: list.asPDFGroups(), config: config)
    }

    /// 便捷初始化：传 PDFList
    convenience init(list: PDFList, config: Config = Config()) {
        self.init(title: list.title, groups: list.groups, config: config)
    }

    /// designated 初始化
    init(title: String, groups: [PDFGroup], config: Config = Config()) {
        self.listTitle = title
        self.groups = groups
        self.config = config
    }

    // MARK: 公开方法

    @discardableResult
    func render(to fileURL: URL) -> URL {
        let format = UIGraphicsPDFRendererFormat()
        let bounds = CGRect(origin: .zero, size: config.pageSize)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds, format: format)
        let totalPages = calculateTotalPages()

        try? FileManager.default.removeItem(at: fileURL)
        try? renderer.writePDF(to: fileURL) { context in
            self.renderPages(in: context, totalPages: totalPages)
        }

        return fileURL
    }

    func renderData() -> Data {
        let format = UIGraphicsPDFRendererFormat()
        let bounds = CGRect(origin: .zero, size: config.pageSize)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds, format: format)
        let totalPages = calculateTotalPages()
        return renderer.pdfData { context in
            self.renderPages(in: context, totalPages: totalPages)
        }
    }

    // MARK: 分页渲染

    private func renderPages(in context: UIGraphicsPDFRendererContext, totalPages: Int) {
        var currentPage = 1
        context.beginPage()
        drawHeader(in: context.cgContext) // 第一页绘制标题
        drawFooter(pageIndex: currentPage, totalPages: totalPages, in: context.cgContext)

        var cursor = firstPageTopY // 第一页使用包含标题的顶部位置
        var isFirstOnPage = true

        for group in groups {
            // 绘制分组标题
            let groupTitleH = heightForGroupTitle(group.title)
            if cursor + groupTitleH > contentBottomY {
                context.beginPage()
                currentPage += 1
                drawFooter(pageIndex: currentPage, totalPages: totalPages, in: context.cgContext)
                cursor = subsequentPageTopY // 后续页使用页面顶部
                isFirstOnPage = true
            }
            
            if !isFirstOnPage { cursor += config.groupTitleTopGap }
            cursor = drawGroupTitle(group.title, at: cursor, in: context.cgContext)
            isFirstOnPage = false
            
            for task in group.tasks {
                let h = height(for: task)
                if cursor + h > contentBottomY {
                    context.beginPage()
                    currentPage += 1
                    drawFooter(pageIndex: currentPage, totalPages: totalPages, in: context.cgContext)
                    cursor = subsequentPageTopY // 后续页使用页面顶部
                    isFirstOnPage = true
                }
                if !isFirstOnPage { cursor += config.taskBlockGap }
                cursor = drawTask(task, at: cursor, in: context.cgContext)
                isFirstOnPage = false
            }
        }
    }
    
    // MARK: 布局

    // 第一页的顶部位置（包含标题）
    private var firstPageTopY: CGFloat {
        config.pageMargins.top + config.titleFont.lineHeight + config.titleBottomGap + config.dividerWidth + 20
    }

    // 后续页的顶部位置（没有标题）
    private var subsequentPageTopY: CGFloat {
        config.pageMargins.top
    }

    private var contentLeftX: CGFloat { config.pageMargins.left }
    private var contentRightX: CGFloat { config.pageSize.width - config.pageMargins.right }
    private var contentTopY: CGFloat {
        config.pageMargins.top + config.titleFont.lineHeight + config.titleBottomGap + config.dividerWidth + 20
    }
    
    private var contentBottomY: CGFloat {
        config.pageSize.height - config.pageMargins.bottom - config.footerFont.lineHeight - 8
    }

    // 优先级圆点预留尺寸（无论是否绘制，都统一预留，保证主任务/子步骤对齐）
    private var priorityDotD: CGFloat { 8 }
    private var priorityDotGap: CGFloat { 6 }

    /// 复选框/进度环实际直径（主任务）
    private func indicatorDiameter(for task: PDFTask) -> CGFloat {
        if task.progress != nil {
            return config.progressRingDiameter
        }
        return config.checkboxDiameter
    }

    /// 复选框/进度环实际直径（子步骤）
    private func indicatorDiameter(for subStep: PDFSubStep) -> CGFloat {
        if subStep.progress != nil {
            return config.progressRingDiameter * 0.8
        }
        return config.checkboxDiameter * 0.8
    }

    /// 文本起始 X（复选框之后、文字开始处）
    private func textStartX(indentX: CGFloat, indicatorD: CGFloat) -> CGFloat {
        indentX + priorityDotD + priorityDotGap + indicatorD + config.checkboxTextGap
    }

    /// 文本可用宽度（扣除右侧标签）
    private func textAvailableWidth(indentX: CGFloat, indicatorD: CGFloat, tag: String?, font: UIFont) -> CGFloat {
        var right = contentRightX
        if config.showsTag, let tag = tag {
            let tagSize = (tag as NSString).size(withAttributes: [.font: font])
            right -= tagSize.width + 8
        }
        return right - textStartX(indentX: indentX, indicatorD: indicatorD)
    }

    /// 计算文本换行后的实际行高（最小保证单行高度）
    private func textLineHeight(for text: String, font: UIFont, maxWidth: CGFloat, minHeight: CGFloat) -> CGFloat {
        guard !text.isEmpty else { return minHeight }
        let p = NSMutableParagraphStyle()
        p.alignment = .left; p.lineBreakMode = .byWordWrapping
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .paragraphStyle: p]
        let size = (text as NSString).boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attrs, context: nil
        ).size
        return max(minHeight, ceil(size.height))
    }

    private func heightForGroupTitle(_ title: String) -> CGFloat {
        return config.groupTitleTopGap + config.groupTitleFont.lineHeight + config.groupTitleBottomGap
    }

    private func height(for task: PDFTask) -> CGFloat {
        var h: CGFloat = 0
        h += textLineHeight(
            for: task.title, font: config.taskFont,
            maxWidth: textAvailableWidth(indentX: contentLeftX, indicatorD: indicatorDiameter(for: task), tag: task.tag, font: config.taskFont),
            minHeight: max(config.taskRowHeight, indicatorDiameter(for: task) + 2)
        )
        
        // 添加主任务 note 高度（包含与主任务底部间距）
        if let note = task.note, note.count > 0 {
            h += config.taskNoteTopGap + config.noteRowHeight
        }
        
        // 递归计算子步骤高度
        for sub in task.subSteps {
            h += heightForSubStep(sub, indentX: contentLeftX + config.subStepIndent)
        }
        
        h += 4.0 // 虚线
        return h
    }
    
    private func heightForSubStep(_ subStep: PDFSubStep, indentX: CGFloat) -> CGFloat {
        var h: CGFloat = 0
        let subIndicatorD = indicatorDiameter(for: subStep)
        h += textLineHeight(
            for: subStep.title, font: config.subStepFont,
            maxWidth: textAvailableWidth(indentX: indentX, indicatorD: subIndicatorD, tag: nil, font: config.subStepFont),
            minHeight: max(config.subStepRowHeight, subIndicatorD + 2)
        )
        if let note = subStep.note, note.count > 0 { h += config.noteRowHeight }
        
        // 递归计算子步骤的子步骤
        if let subSteps = subStep.subSteps {
            for subSubStep in subSteps {
                h += heightForSubStep(subSubStep, indentX: indentX + config.subStepIndent)
            }
        }
        
        return h
    }

    private func calculateTotalPages() -> Int {
        var pages = 1
        var cursor = firstPageTopY // 第一页使用包含标题的顶部位置
        var isFirstOnPage = true
        
        for group in groups {
            
            // 分组标题高度
            let groupTitleH = heightForGroupTitle(group.title) + (isFirstOnPage ? 0 : config.groupTitleTopGap)
            if cursor + groupTitleH > contentBottomY {
                pages += 1
                cursor = subsequentPageTopY // 后续页使用页面顶部
                isFirstOnPage = true
            }
            cursor += groupTitleH
            isFirstOnPage = false
            
            for task in group.tasks {
                let h = height(for: task)
                if cursor + h > contentBottomY {
                    pages += 1
                    cursor = subsequentPageTopY // 后续页使用页面顶部
                    isFirstOnPage = true
                }
                if !isFirstOnPage { cursor += config.taskBlockGap }
                cursor += h
                isFirstOnPage = false
            }
        }
        
        return pages
    }

    // MARK: 绘制

    private func drawHeader(in ctx: CGContext) {
        ctx.saveGState()
        let topY = config.pageMargins.top
        
        // 标题
        let titleX = contentLeftX + 14.0
        let titleRect = CGRect(x: titleX, y: topY, width: contentRightX - titleX, height: config.titleFont.lineHeight)
        let p = NSMutableParagraphStyle()
        p.alignment = .left
        (listTitle as NSString).draw(in: titleRect, withAttributes: [
            .font: config.titleFont, .foregroundColor: UIColor.black, .paragraphStyle: p
        ])

        // 实线
        let dividerY = topY + config.titleFont.lineHeight + config.titleBottomGap
        ctx.setLineWidth(config.dividerWidth)
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.move(to: CGPoint(x: contentLeftX, y: dividerY))
        ctx.addLine(to: CGPoint(x: contentRightX, y: dividerY))
        ctx.strokePath()
        ctx.restoreGState()
    }
    
    @discardableResult
    private func drawGroupTitle(_ title: String, at y: CGFloat, in ctx: CGContext) -> CGFloat {
        ctx.saveGState()
        
        var cur = y
        let titleRect = CGRect(x: contentLeftX, y: cur, width: contentRightX - contentLeftX, height: config.groupTitleFont.lineHeight)
        let p = NSMutableParagraphStyle()
        p.alignment = .left
        
        // 绘制分组标题背景（浅灰色）
        UIColor.lightGray.withAlphaComponent(0.15).setFill()
        UIBezierPath(roundedRect: CGRect(x: contentLeftX - 8, y: cur - 4, width: contentRightX - contentLeftX + 16, height: config.groupTitleFont.lineHeight + 8), cornerRadius: 4).fill()
        
        // 绘制分组标题
        (title as NSString).draw(in: titleRect, withAttributes: [
            .font: config.groupTitleFont, .foregroundColor: UIColor.darkGray, .paragraphStyle: p
        ])
        
        cur += config.groupTitleFont.lineHeight + config.groupTitleBottomGap
        
        ctx.restoreGState()
        return cur
    }
    
    @discardableResult
    private func drawTask(_ task: PDFTask, at y: CGFloat, in ctx: CGContext) -> CGFloat {
        var cur = y
        cur = drawRow(
            title: task.title, isCompleted: task.isCompleted,
            font: config.taskFont, indicatorD: indicatorDiameter(for: task),
            indentX: contentLeftX, at: cur, rowH: config.taskRowHeight,
            priority: task.priority, tag: task.tag, isMainTask: true,
            progress: task.progress, in: ctx
        )
        
        // 绘制主任务 note（与主任务文本开头对齐）
        if let note = task.note, note.count > 0 {
            let mainIndicatorD = indicatorDiameter(for: task)
            let noteIndentX = textStartX(indentX: contentLeftX, indicatorD: mainIndicatorD)
            cur += config.taskNoteTopGap // 添加间距
            cur = drawNote(note, at: cur, indentX: noteIndentX, in: ctx)
        }
        
        // 递归绘制子步骤
        for sub in task.subSteps {
            cur = drawSubStep(sub, at: cur, indentX: contentLeftX + config.subStepIndent, in: ctx)
        }
        
        cur += 15.0
        drawDashedLine(at: cur, in: ctx)
        cur += 2
        return cur
    }
    
    @discardableResult
    private func drawSubStep(_ subStep: PDFSubStep, at y: CGFloat, indentX: CGFloat, in ctx: CGContext) -> CGFloat {
        var cur = y
        cur = drawRow(
            title: subStep.title, isCompleted: subStep.isCompleted,
            font: config.subStepFont, indicatorD: indicatorDiameter(for: subStep),
            indentX: indentX, at: cur,
            rowH: config.subStepRowHeight, priority: nil, tag: nil,
            isMainTask: false, progress: subStep.progress, in: ctx
        )
        
        if let note = subStep.note, note.count > 0 {
            let subIndicatorD = indicatorDiameter(for: subStep)
            cur = drawNote(note, at: cur, indentX: textStartX(indentX: indentX, indicatorD: subIndicatorD), in: ctx)
        }
        
        // 递归绘制子步骤的子步骤
        if let subSteps = subStep.subSteps {
            for subSubStep in subSteps {
                cur = drawSubStep(subSubStep, at: cur, indentX: indentX + config.subStepIndent, in: ctx)
            }
        }
        
        return cur
    }

    private func drawNote(_ text: String, at y: CGFloat, indentX: CGFloat, in ctx: CGContext) -> CGFloat {
        let rect = CGRect(x: indentX, y: y, width: contentRightX - indentX, height: config.noteRowHeight)
        let p = NSMutableParagraphStyle()
        p.alignment = .left
        (text as NSString).draw(in: rect, withAttributes: [
            .font: config.noteFont, .foregroundColor: UIColor.gray, .paragraphStyle: p
        ])
        return y + config.noteRowHeight
    }

    private func drawRow(
        title: String, isCompleted: Bool, font: UIFont, indicatorD: CGFloat,
        indentX: CGFloat, at y: CGFloat, rowH: CGFloat,
        priority: PDFPriority?, tag: String?, isMainTask: Bool,
        progress: Double?, in ctx: CGContext
    ) -> CGFloat {
        ctx.saveGState()

        // 文本实际高度（支持多行换行）
        let textX = textStartX(indentX: indentX, indicatorD: indicatorD)
        let textWidth = textAvailableWidth(indentX: indentX, indicatorD: indicatorD, tag: tag, font: font)
        let textH = textLineHeight(for: title, font: font, maxWidth: textWidth, minHeight: rowH)

        // 指示器起始 X（优先级圆点之后）
        let indicatorStartX = indentX + priorityDotD + priorityDotGap

        // 优先级圆点
        if config.showsPriority, let p = priority {
            let dotY = y + (rowH - priorityDotD) / 2
            p.color.setFill()
            UIBezierPath(ovalIn: CGRect(x: indentX, y: dotY, width: priorityDotD, height: priorityDotD)).fill()
        }

        // 绘制进度环或复选框
        let indicatorY = y + (rowH - indicatorD) / 2
        let indicatorRect = CGRect(x: indicatorStartX, y: indicatorY, width: indicatorD, height: indicatorD)
        if let progress = progress {
            // 绘制圆环进度条
            drawProgressRing(in: indicatorRect, progress: progress, isCompleted: isCompleted, isMainTask: isMainTask, in: ctx)
        } else {
            // 绘制复选框
            drawCheckbox(in: indicatorRect, isCompleted: isCompleted, isMainTask: isMainTask, in: ctx)
        }

        // 标签（右侧，首行垂直居中）
        if config.showsTag, let tag = tag {
            let tagAttrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.gray]
            let tagSize = (tag as NSString).size(withAttributes: tagAttrs)
            let tagY = y + (rowH - font.lineHeight) / 2
            let tagRect = CGRect(x: contentRightX - tagSize.width, y: tagY, width: tagSize.width, height: font.lineHeight)
            (tag as NSString).draw(in: tagRect, withAttributes: tagAttrs)
        }

        // 文字（多行换行，后续行与首行左对齐）
        let firstLineH = font.lineHeight
        let textY = y + (rowH - firstLineH) / 2
        let textRect = CGRect(x: textX, y: textY, width: textWidth, height: textH)
        let p = NSMutableParagraphStyle()
        p.alignment = .left; p.lineBreakMode = .byWordWrapping
        var attrs: [NSAttributedString.Key: Any] = [
            .font: font, .foregroundColor: isCompleted ? UIColor.lightGray : UIColor.black, .paragraphStyle: p
        ]
        if isCompleted {
            attrs[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            attrs[.strikethroughColor] = UIColor.lightGray
        }
        (title as NSString).draw(in: textRect, withAttributes: attrs)

        ctx.restoreGState()
        return y + textH
    }

    /// 绘制圆环进度条
    private func drawProgressRing(in rect: CGRect, progress: Double, isCompleted: Bool, isMainTask: Bool, in ctx: CGContext) {
        ctx.saveGState()
        
        let lineWidth = isMainTask ? config.progressRingWidth : config.progressRingWidth * 0.8
        let clampedProgress = min(max(progress, 0.0), 1.0)
        
        // 背景圆环
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = (rect.width - lineWidth) / 2
        
        // 背景环
        let bgPath = UIBezierPath(arcCenter: center, radius: radius,
                                  startAngle: -CGFloat.pi / 2,
                                  endAngle: CGFloat.pi * 1.5,
                                  clockwise: true)
        bgPath.lineWidth = lineWidth
        UIColor.lightGray.withAlphaComponent(0.3).setStroke()
        bgPath.stroke()
        
        // 进度环
        if clampedProgress > 0 {
            let progressPath = UIBezierPath(arcCenter: center, radius: radius,
                                            startAngle: -CGFloat.pi / 2,
                                            endAngle: -CGFloat.pi / 2 + CGFloat.pi * 2 * CGFloat(clampedProgress),
                                            clockwise: true)
            progressPath.lineWidth = lineWidth
            progressPath.lineCapStyle = .round
            
            // 根据完成状态选择颜色
            if isCompleted {
                UIColor.black.setStroke()
            } else if clampedProgress >= 1.0 {
                UIColor.systemGreen.setStroke()
            } else if clampedProgress > 0.7 {
                UIColor.systemOrange.setStroke()
            } else {
                UIColor.systemBlue.setStroke()
            }
            
            progressPath.stroke()
        }
        
        ctx.restoreGState()
    }
    
    /// 绘制复选框
    private func drawCheckbox(in rect: CGRect, isCompleted: Bool, isMainTask: Bool, in ctx: CGContext) {
        ctx.saveGState()
        
        if isMainTask {
            // 主任务：圆角矩形
            let path = UIBezierPath(roundedRect: rect, cornerRadius: config.checkboxCornerRadius)
            if isCompleted {
                UIColor.black.setFill()
                path.fill()
                UIColor.white.setStroke()
                ctx.setLineWidth(config.checkboxBorderWidth); ctx.setLineCap(.round); ctx.setLineJoin(.round)
                ctx.move(to: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.midY + rect.height * 0.08))
                ctx.addLine(to: CGPoint(x: rect.minX + rect.width * 0.46, y: rect.midY + rect.height * 0.24))
                ctx.addLine(to: CGPoint(x: rect.minX + rect.width * 0.75, y: rect.midY - rect.height * 0.22))
                ctx.strokePath()
            } else {
                UIColor.black.setStroke()
                ctx.setLineWidth(config.checkboxBorderWidth)
                UIBezierPath(roundedRect: rect.insetBy(dx: config.checkboxBorderWidth / 2.0, dy: config.checkboxBorderWidth / 2.0), cornerRadius: config.checkboxCornerRadius).stroke()
            }
        } else {
            // 子步骤：圆圈
            if isCompleted {
                UIColor.black.setFill()
                UIBezierPath(ovalIn: rect).fill()
                UIColor.white.setStroke()
                ctx.setLineWidth(config.checkboxBorderWidth); ctx.setLineCap(.round); ctx.setLineJoin(.round)
                ctx.move(to: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.midY + rect.height * 0.08))
                ctx.addLine(to: CGPoint(x: rect.minX + rect.width * 0.45, y: rect.midY + rect.height * 0.28))
                ctx.addLine(to: CGPoint(x: rect.minX + rect.width * 0.75, y: rect.midY - rect.height * 0.22))
                ctx.strokePath()
            } else {
                UIColor.black.setStroke()
                ctx.setLineWidth(config.checkboxBorderWidth)
                UIBezierPath(ovalIn: rect.insetBy(dx: config.checkboxBorderWidth / 2.0, dy: config.checkboxBorderWidth / 2.0)).stroke()
            }
        }
        
        ctx.restoreGState()
    }

    private func drawDashedLine(at y: CGFloat, in ctx: CGContext) {
        ctx.saveGState()
        ctx.setStrokeColor(UIColor.lightGray.cgColor)
        ctx.setLineWidth(0.8)
        ctx.setLineDash(phase: 0, lengths: [3, 3])
        ctx.move(to: CGPoint(x: contentLeftX, y: y))
        ctx.addLine(to: CGPoint(x: contentRightX, y: y))
        ctx.strokePath()
        ctx.restoreGState()
    }

    private func drawFooter(pageIndex: Int, totalPages: Int, in ctx: CGContext) {
        ctx.saveGState()
        let footerY = config.pageSize.height - config.pageMargins.bottom
        let fh = config.footerFont.lineHeight
        let base: [NSAttributedString.Key: Any] = [.font: config.footerFont, .foregroundColor: UIColor.darkGray]

        let df = DateFormatter(); df.dateFormat = "yyyy/M/d"
        let p = NSMutableParagraphStyle()

        p.alignment = .left
        (df.string(from: config.exportDate) as NSString).draw(
            in: CGRect(x: contentLeftX, y: footerY, width: 150, height: fh),
            withAttributes: base.merging([.paragraphStyle: p]) { $1 })

        p.alignment = .center
        (config.footerBrandText as NSString).draw(
            in: CGRect(x: contentLeftX, y: footerY, width: contentRightX - contentLeftX, height: fh),
            withAttributes: base.merging([.paragraphStyle: p]) { $1 })

        p.alignment = .right
        ("Page \(pageIndex) of \(totalPages)" as NSString).draw(
            in: CGRect(x: contentRightX - 150, y: footerY, width: 150, height: fh),
            withAttributes: base.merging([.paragraphStyle: p]) { $1 })

        ctx.restoreGState()
    }
}

class TodoPDFMananger {
    
    static func printList(_ list: PDFList) {
        let renderer = TodoPDFRenderer(title: list.title, groups: list.groups)
        TPLoadingIndicator.showLoading(resGetString("Generating PDF..."))
        // 2. 在后台线程渲染 PDF
        DispatchQueue.global(qos: .userInitiated).async {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("output.pdf")
            renderer.render(to: url)
            
            // 3. 回到主线程更新 UI
            DispatchQueue.main.async {
                TPLoadingIndicator.hideLoading()
                presentPrintPreview(for: url, jobTitle: list.title)
            }
        }
    }
    
    /// 弹出系统打印预览面板
    private static func presentPrintPreview(for pdfURL: URL, jobTitle: String) {
        guard UIPrintInteractionController.isPrintingAvailable else {
            debugPrint("当前设备不支持打印功能")
            return
        }
        
        let printController = UIPrintInteractionController.shared
        
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = jobTitle
        printInfo.orientation = .portrait
        printController.printInfo = printInfo
        printController.printingItem = pdfURL
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            guard let view = UIWindow.keyWindow else { return }
            printController.present(from: view.bounds,
                                    in: view,
                                    animated: true,
                                    completionHandler: nil)
        } else {
            printController.present(animated: true, completionHandler: nil)
        }
    }
}
