//
//  TodoStepImporter.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/22.
//

import Foundation

class TodoStepImporter {
    
    // MARK: - 解析结果
    struct ParseResult {
        var rootSteps: [TodoStep] = []
        var errors: [ParseError] = []
    }
    
    struct ParseError {
        let lineNumber: Int
        let message: String
        let line: String
    }
    
    // MARK: - 主要解析方法
    func parse(text: String) -> ParseResult {
        var result = ParseResult()
        let lines = text.components(separatedBy: .newlines)
        
        // 步骤栈：用于跟踪缩进层级，元素为 (缩进级别, 父步骤)
        var stepStack: [(indentLevel: Int, parentStep: TodoStep)] = []
        
        for (index, line) in lines.enumerated() {
            let lineNumber = index + 1
            
            // 跳过空行
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine.isEmpty {
                continue
            }
            
            // 计算缩进级别
            let indentLevel = calculateIndentLevel(line)
            
            // 解析步骤内容（Markdown 格式或纯文本）
            guard let (content, isCompleted) = parseStepContent(line) else {
                result.errors.append(ParseError(
                    lineNumber: lineNumber,
                    message: "无法解析该行",
                    line: line
                ))
                continue
            }
            
            // 创建新的步骤
            let newStep = TodoStep(content: content, isCompleted: isCompleted)
            
            // 确定父步骤
            if let parentStep = findParentStep(for: indentLevel, in: &stepStack) {
                parentStep.subSteps.append(newStep)
                newStep.parent = parentStep
            } else {
                // 无法确定父步骤时，添加到根层级
                result.rootSteps.append(newStep)
                // 清空栈，重新开始
                stepStack.removeAll()
            }
            
            // 更新步骤栈
            updateStepStack(with: newStep, indentLevel: indentLevel, in: &stepStack)
        }
        
        return result
    }
    
    // MARK: - 私有辅助方法
    
    /// 计算行的缩进级别（以2个空格为基本单位，容错处理）
    private func calculateIndentLevel(_ line: String) -> Int {
        var spaceCount = 0
        
        for char in line {
            if char == " " {
                spaceCount += 1
            } else if char == "\t" {
                // Tab 键视为 2-4 个空格的级别
                spaceCount += 3
                break
            } else {
                break
            }
        }
        
        // 将空格数转换为缩进级别，支持容错
        // 2-3个空格算1级，4-5个空格算2级，以此类推
        if spaceCount == 0 {
            return 0
        } else if spaceCount <= 3 {
            return 1
        } else {
            // 每增加2个空格增加一个级别，但留有余地
            return Int(ceil(Double(spaceCount) / 2.0))
        }
    }
    
    /// 解析步骤内容，支持 Markdown 格式
    private func parseStepContent(_ line: String) -> (content: String, isCompleted: Bool)? {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        
        // Markdown 已完成：- [x] 或 - [X] 内容
        let completedPattern = #"^[-*+]\s*\[[xX]\]\s+(.+)$"#
        // Markdown 未完成：- [ ] 内容
        let uncompletedPattern = #"^[-*+]\s*\[\s\]\s+(.+)$"#
        // Markdown 简单列表：- 内容 或 * 内容
        let listPattern = #"^[-*+]\s+(.+)$"#
        
        // 检查已完成状态
        if let match = try? NSRegularExpression(pattern: completedPattern, options: [])
            .firstMatch(in: trimmedLine, options: [], range: NSRange(location: 0, length: trimmedLine.utf16.count)),
           let contentRange = Range(match.range(at: 1), in: trimmedLine) {
            return (String(trimmedLine[contentRange]), true)
        }
        
        // 检查未完成状态
        if let match = try? NSRegularExpression(pattern: uncompletedPattern, options: [])
            .firstMatch(in: trimmedLine, options: [], range: NSRange(location: 0, length: trimmedLine.utf16.count)),
           let contentRange = Range(match.range(at: 1), in: trimmedLine) {
            return (String(trimmedLine[contentRange]), false)
        }
        
        // 检查列表格式（去掉列表标记）
        if let match = try? NSRegularExpression(pattern: listPattern, options: [])
            .firstMatch(in: trimmedLine, options: [], range: NSRange(location: 0, length: trimmedLine.utf16.count)),
           let contentRange = Range(match.range(at: 1), in: trimmedLine) {
            return (String(trimmedLine[contentRange]), false)
        }
        
        // 纯文本格式：直接作为内容
        if !trimmedLine.isEmpty {
            return (trimmedLine, false)
        }
        
        return nil
    }
    
    /// 查找父步骤（容错处理）
    private func findParentStep(for indentLevel: Int, in stack: inout [(indentLevel: Int, parentStep: TodoStep)]) -> TodoStep? {
        if indentLevel == 0 {
            return nil
        }
        
        // 从栈中查找缩进级别小于当前级别的最近步骤
        for item in stack.reversed() {
            if item.indentLevel < indentLevel {
                return item.parentStep
            }
        }
        
        return nil
    }
    
    /// 更新步骤栈
    private func updateStepStack(with step: TodoStep, indentLevel: Int, in stack: inout [(indentLevel: Int, parentStep: TodoStep)]) {
        // 移除所有缩进级别大于或等于当前级别的步骤
        while let last = stack.last, last.indentLevel >= indentLevel {
            stack.removeLast()
        }
        
        // 添加当前步骤到栈中
        stack.append((indentLevel: indentLevel, parentStep: step))
    }
}

// MARK: - 扩展：便捷方法
extension TodoStepImporter {
    
    /// 批量导入并返回根步骤数组
    func importSteps(from text: String) -> [TodoStep] {
        let result = parse(text: text)
        
        // 如果有错误，可以在这里处理或记录
        if !result.errors.isEmpty {
            print("解析警告：")
            for error in result.errors {
                print("第\(error.lineNumber)行: \(error.message) - \"\(error.line)\"")
            }
        }
        
        return result.rootSteps
    }
    
    /// 将步骤树转换为可视化字符串（用于调试）
    func visualize(_ steps: [TodoStep], indent: Int = 0) -> String {
        var result = ""
        let indentString = String(repeating: "  ", count: indent)
        
        for step in steps {
            let status = step.isCompleted ? "[✓]" : "[ ]"
            result += "\(indentString)\(status) \(step.content)\n"
            if step.isExpanded && !step.subSteps.isEmpty {
                result += visualize(step.subSteps, indent: indent + 1)
            }
        }
        
        return result
    }
}

// MARK: - 使用示例
extension TodoStepImporter {
    
    static func example() {
        let parser = TodoStepImporter()
        
        let inputText = """
        完成项目报告
          - [x] 收集数据
            - [ ] 销售数据
            - [ ] 用户反馈
          - [ ] 编写分析
        准备会议
          - [ ] 制作PPT
          - [ ] 预定会议室
        买水果
        """
        
        let steps = parser.importSteps(from: inputText)
        print("解析结果：")
        print(parser.visualize(steps))
        
        // 遍历步骤树
        print("\n步骤详情：")
        func printStep(_ step: TodoStep, level: Int = 0) {
            let indent = String(repeating: "  ", count: level)
            print("\(indent)📝 \(step.content) [\(step.isCompleted ? "完成" : "未完成")]")
            for subStep in step.subSteps {
                printStep(subStep, level: level + 1)
            }
        }
        
        for step in steps {
            printStep(step)
        }
    }
}
