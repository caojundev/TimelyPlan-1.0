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

    init(title: String, isCompleted: Bool = false, note: String? = nil) {
        self.title = title
        self.isCompleted = isCompleted
        self.note = note
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

    init(
        title: String,
        isCompleted: Bool = false,
        subSteps: [PDFSubStep] = [],
        priority: PDFPriority? = nil,
        tag: String? = nil
    ) {
        self.title = title
        self.isCompleted = isCompleted
        self.subSteps = subSteps
        self.priority = priority
        self.tag = tag
    }
}

/// PDF 清单
struct PDFList {
    let title: String
    let tasks: [PDFTask]
}

// MARK: - 转换协议（核心：任何模型实现它就能打印）

/// 单个任务可转换协议
protocol PDFTaskConvertible {
    func asPDFTask() -> PDFTask
}

/// 整个清单可转换协议
protocol PDFListConvertible {
    var pdfTitle: String { get }
    func asPDFTasks() -> [PDFTask]
}

// MARK: - 业务模型示例（你的任意模型都可以这样扩展）

// 示例 1：Todo 业务模型
struct TodoItem {
    let id: String
    let content: String
    let done: Bool
    let children: [TodoItem]
    let priorityLevel: Int // 0=无, 1=低, 2=中, 3=高
    let dueDate: Date?
}

extension TodoItem: PDFTaskConvertible {
    func asPDFTask() -> PDFTask {
        let p: PDFPriority?
        switch priorityLevel {
        case 1: p = .low
        case 2: p = .medium
        case 3: p = .high
        default: p = nil
        }
        let tag = dueDate.map { date -> String in
            let f = DateFormatter()
            f.dateFormat = "MM/dd"
            return f.string(from: date)
        }
        return PDFTask(
            title: content,
            isCompleted: done,
            subSteps: children.map { $0.asPDFSubStep() },
            priority: p,
            tag: tag
        )
    }

    private func asPDFSubStep() -> PDFSubStep {
        PDFSubStep(title: content, isCompleted: done)
    }
}

// 示例 3：备忘录 / 纯文本笔记
struct Note {
    let title: String
    let body: String
}

extension Note: PDFTaskConvertible {
    func asPDFTask() -> PDFTask {
        // 把正文按换行拆成子步骤
        let lines = body.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .map { PDFSubStep(title: $0, isCompleted: false) }
        return PDFTask(title: title, isCompleted: false, subSteps: lines)
    }
}

// 示例 4：数组直接扩展，让 [PDFTaskConvertible] 可以整体转换
extension Array: PDFListConvertible where Element: PDFTaskConvertible {
    var pdfTitle: String { "待办清单" }
    func asPDFTasks() -> [PDFTask] { map { $0.asPDFTask() } }
}

// MARK: - PDF 渲染器

final class TodoPDFRenderer {

    struct Config {
        var pageSize = CGSize(width: 595.2, height: 841.8) // A4
        var pageMargins = UIEdgeInsets(top: 48, left: 56, bottom: 48, right: 56)
        var titleFont: UIFont = .systemFont(ofSize: 26, weight: .bold)
        var taskFont: UIFont = .systemFont(ofSize: 15, weight: .regular)
        var subStepFont: UIFont = .systemFont(ofSize: 13, weight: .regular)
        var noteFont: UIFont = .systemFont(ofSize: 11, weight: .regular)
        var footerFont: UIFont = .systemFont(ofSize: 9, weight: .regular)
        var checkboxDiameter: CGFloat = 16
        var checkboxTextGap: CGFloat = 10
        var subStepIndent: CGFloat = 30
        var titleBottomGap: CGFloat = 14
        var dividerWidth: CGFloat = 1.2
        var taskRowHeight: CGFloat = 28
        var subStepRowHeight: CGFloat = 22
        var noteRowHeight: CGFloat = 18
        var taskBlockGap: CGFloat = 6
        var footerBrandText = "Printed with MyApp"
        var exportDate: Date = Date()
        /// 是否显示优先级圆点
        var showsPriority = true
        /// 是否显示标签
        var showsTag = true
    }

    private let tasks: [PDFTask]
    private let listTitle: String
    private let config: Config

    /// 便捷初始化：直接传协议数组
    convenience init(title: String, items: [PDFTaskConvertible], config: Config = Config()) {
        self.init(title: title, tasks: items.map { $0.asPDFTask() }, config: config)
    }

    /// 便捷初始化：传整个可转换清单
    convenience init(list: PDFListConvertible, config: Config = Config()) {
        self.init(title: list.pdfTitle, tasks: list.asPDFTasks(), config: config)
    }

    ///  designated 初始化
    init(title: String, tasks: [PDFTask], config: Config = Config()) {
        self.listTitle = title
        self.tasks = tasks
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
        drawHeader(in: context.cgContext)
        drawFooter(pageIndex: currentPage, totalPages: totalPages, in: context.cgContext)

        var cursor = contentTopY
        var isFirstOnPage = true

        for task in tasks {
            let h = height(for: task)
            if cursor + h > contentBottomY {
                context.beginPage()
                currentPage += 1
                drawHeader(in: context.cgContext)
                drawFooter(pageIndex: currentPage, totalPages: totalPages, in: context.cgContext)
                cursor = contentTopY
                isFirstOnPage = true
            }
            if !isFirstOnPage { cursor += config.taskBlockGap }
            cursor = drawTask(task, at: cursor, in: context.cgContext)
            isFirstOnPage = false
        }
    }

    // MARK: 布局

    private var contentLeftX: CGFloat { config.pageMargins.left }
    private var contentRightX: CGFloat { config.pageSize.width - config.pageMargins.right }
    private var contentTopY: CGFloat {
        config.pageMargins.top + config.titleFont.lineHeight + config.titleBottomGap + config.dividerWidth + 20
    }
    private var contentBottomY: CGFloat {
        config.pageSize.height - config.pageMargins.bottom - config.footerFont.lineHeight - 8
    }

    private func height(for task: PDFTask) -> CGFloat {
        var h: CGFloat = config.taskRowHeight
        for sub in task.subSteps {
            h += config.subStepRowHeight
            if sub.note != nil { h += config.noteRowHeight }
        }
        h += 4 // 虚线
        return h
    }

    private func calculateTotalPages() -> Int {
        var pages = 1, cursor = contentTopY, first = true
        for task in tasks {
            let h = height(for: task)
            if cursor + h > contentBottomY { pages += 1; cursor = contentTopY; first = true }
            if !first { cursor += config.taskBlockGap }
            cursor += h; first = false
        }
        return pages
    }

    // MARK: 绘制

    private func drawHeader(in ctx: CGContext) {
        ctx.saveGState()
        let topY = config.pageMargins.top

        // 列表图标
        let iconSize: CGFloat = 22
        let iconY = topY + (config.titleFont.lineHeight - iconSize) / 2 + 2
        drawListIcon(at: CGPoint(x: contentLeftX, y: iconY), size: iconSize, in: ctx)

        // 标题
        let titleX = contentLeftX + iconSize + 14
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

    private func drawListIcon(at origin: CGPoint, size: CGFloat, in ctx: CGContext) {
        let lineH: CGFloat = 2.2
        let gap = (size - lineH * 3) / 2
        let w = size * 0.75
        for i in 0..<3 {
            let y = origin.y + CGFloat(i) * (lineH + gap)
            UIBezierPath(roundedRect: CGRect(x: origin.x, y: y, width: w, height: lineH), cornerRadius: lineH / 2).fill()
        }
    }

    @discardableResult
    private func drawTask(_ task: PDFTask, at y: CGFloat, in ctx: CGContext) -> CGFloat {
        var cur = y
        cur = drawRow(
            title: task.title, isCompleted: task.isCompleted,
            font: config.taskFont, checkboxD: config.checkboxDiameter,
            indentX: contentLeftX, at: cur, rowH: config.taskRowHeight,
            priority: task.priority, tag: task.tag, in: ctx
        )
        for sub in task.subSteps {
            cur = drawRow(
                title: sub.title, isCompleted: sub.isCompleted,
                font: config.subStepFont, checkboxD: config.checkboxDiameter * 0.8,
                indentX: contentLeftX + config.subStepIndent, at: cur,
                rowH: config.subStepRowHeight, priority: nil, tag: nil, in: ctx
            )
            if let note = sub.note {
                cur = drawNote(note, at: cur, indentX: contentLeftX + config.subStepIndent + config.checkboxDiameter * 0.8 + config.checkboxTextGap, in: ctx)
            }
        }
        cur += 2
        drawDashedLine(at: cur, in: ctx)
        cur += 2
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
        title: String, isCompleted: Bool, font: UIFont, checkboxD: CGFloat,
        indentX: CGFloat, at y: CGFloat, rowH: CGFloat,
        priority: PDFPriority?, tag: String?, in ctx: CGContext
    ) -> CGFloat {
        ctx.saveGState()

        // 优先级圆点
        var textStartX = indentX
        if config.showsPriority, let p = priority {
            let dotD: CGFloat = 8
            let dotY = y + (rowH - dotD) / 2
            p.color.setFill()
            UIBezierPath(ovalIn: CGRect(x: indentX, y: dotY, width: dotD, height: dotD)).fill()
            textStartX += dotD + 6
        }

        // 复选框
        let cbY = y + (rowH - checkboxD) / 2
        let cbRect = CGRect(x: textStartX, y: cbY, width: checkboxD, height: checkboxD)
        if isCompleted {
            UIColor.black.setFill()
            UIBezierPath(ovalIn: cbRect).fill()
            UIColor.white.setStroke()
            ctx.setLineWidth(1.8); ctx.setLineCap(.round)
            ctx.move(to: CGPoint(x: cbRect.minX + checkboxD * 0.25, y: cbRect.midY + checkboxD * 0.08))
            ctx.addLine(to: CGPoint(x: cbRect.minX + checkboxD * 0.45, y: cbRect.midY + checkboxD * 0.28))
            ctx.addLine(to: CGPoint(x: cbRect.minX + checkboxD * 0.75, y: cbRect.midY - checkboxD * 0.22))
            ctx.strokePath()
        } else {
            UIColor.black.setStroke()
            ctx.setLineWidth(1.2)
            UIBezierPath(ovalIn: cbRect.insetBy(dx: 0.6, dy: 0.6)).stroke()
        }

        // 标签（右侧）
        var textRight = contentRightX
        if config.showsTag, let tag = tag {
            let tagAttrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.gray]
            let tagSize = (tag as NSString).size(withAttributes: tagAttrs)
            let tagRect = CGRect(x: contentRightX - tagSize.width, y: y, width: tagSize.width, height: rowH)
            (tag as NSString).draw(in: tagRect, withAttributes: tagAttrs)
            textRight = contentRightX - tagSize.width - 8
        }

        // 文字
        let textX = textStartX + checkboxD + config.checkboxTextGap
        let textRect = CGRect(x: textX, y: y, width: textRight - textX, height: rowH)
        let p = NSMutableParagraphStyle()
        p.alignment = .left; p.lineBreakMode = .byTruncatingTail
        var attrs: [NSAttributedString.Key: Any] = [
            .font: font, .foregroundColor: isCompleted ? UIColor.lightGray : UIColor.black, .paragraphStyle: p
        ]
        if isCompleted {
            attrs[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            attrs[.strikethroughColor] = UIColor.lightGray
        }
        (title as NSString).draw(in: textRect, withAttributes: attrs)

        ctx.restoreGState()
        return y + rowH
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
    
    static func printMixedList() {
        // 混合不同业务模型，只要都实现了 PDFTaskConvertible
        let items: [PDFTaskConvertible] = [
            TodoItem(id: "0", content: "无法暂停，无法跳转下一步", done: true, children: [], priorityLevel: 3, dueDate: Date()),
            TodoItem(id: "1", content: "计时器画中画支持", done: false, children: [], priorityLevel: 3, dueDate: Date()),
            TodoItem(id: "2", content: "严格模式", done: false,
                     children: [TodoItem(id: "2.1", content: "无法暂停，无法跳转下一步", done: false, children: [], priorityLevel: 0, dueDate: nil)],
                     priorityLevel: 2, dueDate: nil),
            Note(title: "灵感记录", body: "试试 PDFKit 替代方案\n研究一下 UIPrintInteractionController"),
        ]

        let renderer = TodoPDFRenderer(title: "专注需求", items: items)
        
        TPLoadingIndicator.showLoading("正在生成 PDF...")
        // 2. 在后台线程渲染 PDF
        DispatchQueue.global(qos: .userInitiated).async {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("output.pdf")
            renderer.render(to: url)
            
            // 3. 回到主线程更新 UI
            DispatchQueue.main.async {
                TPLoadingIndicator.hideLoading()
                presentPrintPreview(for: url, jobTitle: "Print todo list")
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
