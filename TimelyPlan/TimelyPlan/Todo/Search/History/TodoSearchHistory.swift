//
//  TodoSearchHistory.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/25.
//

import Foundation

struct TodoSearchHistory: Codable, Hashable {
    let keyword: String
    let timestamp: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(keyword)
    }
    
    static func == (lhs: TodoSearchHistory, rhs: TodoSearchHistory) -> Bool {
        return lhs.keyword == rhs.keyword
    }
    
    init(keyword: String) {
        self.keyword = keyword
        self.timestamp = Date()
    }
    
    init(keyword: String, timestamp: Date) {
        self.keyword = keyword
        self.timestamp = timestamp
    }
}


// 为 Set 添加扩展方法，实现插入或更新时间戳
extension Set where Element == TodoSearchHistory {
    
    mutating func insertOrUpdate(_ newHistory: TodoSearchHistory) {
        // 移除相同 text 的旧条目
        self.remove(newHistory)
        // 插入新条目（带有最新时间戳）
        self.insert(newHistory)
    }
    
    mutating func insertWithLimit(_ newItem: TodoSearchHistory, maxCount: Int) {
        // 先插入或更新
        if let existing = self.first(where: { $0.keyword == newItem.keyword }) {
            self.remove(existing)
        }
        self.insert(newItem)
        
        // 超过限制则删除最旧的
        if self.count > maxCount {
            let oldest = self.min { $0.timestamp < $1.timestamp }
            if let oldest = oldest {
                self.remove(oldest)
            }
        }
    }
    
    mutating func keepLatest(maxCount: Int) {
        guard self.count > maxCount && maxCount > 0 else { return }
        
        // 按时间戳降序排序，保留最新的 maxCount 条
        let sorted = self.sorted { $0.timestamp > $1.timestamp }
        let toKeep = Set(sorted.prefix(maxCount))
        self = toKeep
    }
    
    func sortByTimestampLatestFirst() -> [TodoSearchHistory] {
        return self.sorted {
            return $0.timestamp > $1.timestamp
        }
    }
}
