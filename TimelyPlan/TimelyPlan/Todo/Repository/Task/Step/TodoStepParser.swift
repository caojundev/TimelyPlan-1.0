//
//  TodoStepParser.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/11.
//

import Foundation

// MARK: - 基于子步骤缩进推断父步骤展开状态的解析器
class TodoStepParser {
    
    struct IndentConfig {
        let baseIndent: Int = 0
        let indentStep: Int = 2  // 每一级缩进的空格数
    }
    
    private let config = IndentConfig()
    
    // MARK: - 辅助数据结构
    private struct ParsedLine {
        let lineNumber: Int
        let indent: Int
        let content: String
        let isCompleted: Bool
    }

    /// 解析 Markdown
    func parse(_ markdown: String) -> [TodoStep] {
        let lines = markdown.components(separatedBy: .newlines)
        let parsedLines = parseLinesWithIndent(lines)
        return buildTree(from: parsedLines)
    }
    
    /// 第一步：解析每一行，记录内容和缩进
    private func parseLinesWithIndent(_ lines: [String]) -> [ParsedLine] {
        var parsedLines: [ParsedLine] = []
        var lineNumber = 0
        
        for line in lines {
            let indent = countLeadingSpaces(line)
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if let (isCompleted, content) = parseTodoLine(trimmedLine) {
                let parsedLine = ParsedLine(
                    lineNumber: lineNumber,
                    indent: indent,
                    content: content,
                    isCompleted: isCompleted
                )
                parsedLines.append(parsedLine)
            }
            lineNumber += 1
        }
        
        return parsedLines
    }
    
    /// 第二步：构建树形结构
    private func buildTree(from lines: [ParsedLine]) -> [TodoStep] {
        var rootSteps: [TodoStep] = []
        var stack: [(step: TodoStep, indent: Int)] = []
        
        for line in lines {
            // 找到父节点：栈中最后一个缩进小于当前行的节点
            while let last = stack.last, last.indent >= line.indent {
                stack.removeLast()
            }
            
            let newStep = TodoStep(
                content: line.content,
                isCompleted: line.isCompleted
            )
            
            if let parent = stack.last {
                // 有父节点
                parent.step.subSteps.append(newStep)
                newStep.parent = parent.step
                
                // 关键：根据当前行的缩进来判断父步骤的展开状态
                // 规则：如果当前行（子步骤）的缩进 == 父步骤缩进 + 2，说明父步骤是折叠的
                //      如果当前行（子步骤）的缩进 == 父步骤缩进 + 4，说明父步骤是折叠的，等等
                let indentDiff = line.indent - parent.indent
                
                // 正常的子步骤应该缩进 indentStep (比如2个空格)
                // 如果缩进大于 indentStep，说明中间有折叠的层级
                if indentDiff > config.indentStep {
                    // 标记父步骤为折叠状态
                    parent.step.isExpanded = false
                    
                    // 如果缩进差异更大，说明有多个折叠层级
                    // 需要向上查找所有应该折叠的祖先节点
                    markAncestorsAsCollapsed(stack: stack,
                                           currentIndent: line.indent,
                                           targetIndent: parent.indent)
                } else {
                    // 正常缩进，父步骤是展开的
                    parent.step.isExpanded = true
                }
            } else {
                // 没有父节点，是根步骤
                rootSteps.append(newStep)
            }
            
            stack.append((newStep, line.indent))
        }
        
        // 后处理：没有子步骤的节点，展开状态设为 false
        postProcessExpandStates(rootSteps)
        
        return rootSteps
    }
    
    /// 标记应该折叠的祖先节点
    private func markAncestorsAsCollapsed(stack: [(step: TodoStep, indent: Int)],
                                          currentIndent: Int,
                                          targetIndent: Int) {
        // 从栈顶向下，标记所有缩进在 targetIndent 和 currentIndent 之间的节点为折叠
        for item in stack.reversed() {
            if item.indent > targetIndent && item.indent < currentIndent {
                item.step.isExpanded = false
            }
            if item.indent <= targetIndent {
                break
            }
        }
    }
    
    /// 后处理展开状态：没有子步骤的节点不应该是展开状态
    private func postProcessExpandStates(_ steps: [TodoStep]) {
        for step in steps {
            if step.subSteps.isEmpty {
                step.isExpanded = false
            } else {
                // 确保有子步骤的节点，如果没有明确设置，默认为 true
                // （已经在初始化时设为 true）
            }
            postProcessExpandStates(step.subSteps)
        }
    }
    
    /// 计算行首空格数
    private func countLeadingSpaces(_ str: String) -> Int {
        var count = 0
        for char in str {
            if char == " " {
                count += 1
            } else if char == "\t" {
                count += config.indentStep
            } else {
                break
            }
        }
        return count
    }
    
    /// 解析待办事项行
    private func parseTodoLine(_ line: String) -> (Bool, String)? {
        let patterns = ["- [ ] ", "- [x] ", "- [X] "]
        
        for pattern in patterns {
            if line.hasPrefix(pattern) {
                let content = String(line.dropFirst(pattern.count))
                let isCompleted = pattern.contains("x") || pattern.contains("X")
                return (isCompleted, content)
            }
        }
        return nil
    }
    
    // MARK: - 转换为 Markdown
    
    /// 将 TodoStep 转换回 Markdown
    /// 根据父步骤的展开状态决定子步骤的缩进
    func toMarkdown(_ steps: [TodoStep],
                    parentIndent: Int = 0,
                    parentIsExpanded: Bool = true,
                    forceExpanded: Bool = false) -> String {
        var result: [String] = []
        
        for step in steps {
            // 当前步骤的缩进等于父步骤的缩进
            let currentIndent = parentIndent
            let indent = String(repeating: " ", count: currentIndent)
            let status = step.isCompleted ? "[x]" : "[ ]"
            
            result.append("\(indent)- \(status) \(step.content)")
            
            if !step.subSteps.isEmpty {
                // 关键：根据当前步骤的展开状态决定子步骤的缩进
                // 如果展开，子步骤缩进 = 当前缩进 + 2
                // 如果折叠，子步骤缩进 = 当前缩进 + 4（表示跳过了一级）
                
                let childIndent: Int
                if forceExpanded {
                    childIndent = currentIndent + 2
                } else {
                    childIndent = step.isExpanded ? currentIndent + 2 : currentIndent + 4
                }
                
                let childMarkdown = toMarkdown(step.subSteps,
                                               parentIndent: childIndent,
                                               parentIsExpanded: step.isExpanded,
                                               forceExpanded: forceExpanded)
                result.append(childMarkdown)
            }
        }
        
        return result.joined(separator: "\n")
    }
}
