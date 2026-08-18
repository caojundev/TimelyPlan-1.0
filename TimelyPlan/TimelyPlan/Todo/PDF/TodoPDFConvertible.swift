//
//  TodoPDFConvertible.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/18.
//

import Foundation

extension TodoGroup: PDFGroupConvertible {
    
    var toPDFGroup: PDFGroup {
        return PDFGroup(title: pdfGroupTitle, tasks: asPDFTasks())
    }
    
    var pdfGroupTitle: String {
        return title ?? resGetString("Untitled Group")
    }

    func asPDFTasks() -> [PDFTask] {
        guard let tasks = tasks else {
            return []
        }
        
        return tasks.map { $0.asPDFTask() }
    }
}

extension TodoTask: PDFTaskConvertible {
    func asPDFTask() -> PDFTask {
        // 转换优先级
        let pdfPriority: PDFPriority?
        switch priority {
        case .none:
            pdfPriority = nil
        case .low:
            pdfPriority = .low
        case .medium:
            pdfPriority = .medium
        case .high:
            pdfPriority = .high
        }
        
        // 转换截止日期为标签
        let tag = dueDateText()
        
        // 转换进度
        let pdfProgress: Double?
        if let progress = progress {
            pdfProgress = progress.completionFraction
        } else {
            pdfProgress = nil
        }
        
        // 转换步骤
        let pdfSubSteps = convertStepsToPDFSubSteps(steps)
        
        return PDFTask(
            title: name ?? resGetString("Untitled"),
            isCompleted: isCompleted,
            subSteps: pdfSubSteps,
            priority: pdfPriority,
            tag: tag,
            progress: pdfProgress,
            note: note
        )
    }
    
    /// 转换步骤数组为 PDFSubStep 数组
    private func convertStepsToPDFSubSteps(_ steps: [TodoStep]?) -> [PDFSubStep] {
        guard let steps = steps, !steps.isEmpty else { return [] }
        
        return steps.map { step in
            convertStepToPDFSubStep(step)
        }
    }
    
    /// 递归转换单个步骤为 PDFSubStep
    private func convertStepToPDFSubStep(_ step: TodoStep) -> PDFSubStep {
        // 递归转换子步骤
        let subSteps: [PDFSubStep]?
        if !step.subSteps.isEmpty {
            subSteps = step.subSteps.map { convertStepToPDFSubStep($0) }
        } else {
            subSteps = nil
        }
        
        return PDFSubStep(
            title: step.content,
            isCompleted: step.isCompleted,
            note: nil,
            progress: nil,
            subSteps: subSteps
        )
    }
    
    /// 获取截止日期文本
    private func dueDateText() -> String? {
        guard let dueDate = schedule?.dateInfo?.endDate else { return nil }
        let isThisYear = dueDate.year == Date().year
        let formatter = DateFormatter()
        formatter.dateFormat = isThisYear ? "MM/dd" : "yyyy/MM/dd"
        return formatter.string(from: dueDate)
    }
}
