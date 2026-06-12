//
//  CalendarVisibilityManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/12.
//

import Foundation
import EventKit

final class CalendarVisibilityManager {
    
    static let shared = CalendarVisibilityManager()
    
    private let snapshotsKey = "calendar_snapshots_v1"
    private var snapshots: [CalendarSnapshot] = []
    
    private init() {
        loadSnapshots()
    }
    
    // MARK: - 持久化读写
    
    private func loadSnapshots() {
        guard let data = UserDefaults.standard.data(forKey: snapshotsKey),
              let decoded = try? JSONDecoder().decode([CalendarSnapshot].self, from: data)
        else {
            snapshots = []
            return
        }
        snapshots = decoded
    }
    
    private func saveSnapshots() {
        if let data = try? JSONEncoder().encode(snapshots) {
            UserDefaults.standard.set(data, forKey: snapshotsKey)
        }
    }
    
    // MARK: - 核心：同步并解析可见性
    
    /// 每次获取日历列表后调用，返回当前应显示的日历
    /// - Parameter currentCalendars: 从 EKEventStore 获取的最新日历列表
    /// - Returns: 过滤后的可见日历数组
    func resolveVisibleCalendars(from currentCalendars: [EKCalendar]) -> [EKCalendar] {
        var migrated = false
        var resolvedHiddenIdentifiers: Set<String> = []
        
        // 构建当前日历的指纹索引，加速查找
        let fingerprintMap: [String: EKCalendar] = Dictionary(
            uniqueKeysWithValues: currentCalendars.map {
                ("\($0.source?.title ?? "")::\($0.title)", $0)
            }
        )
        
        // 遍历已保存的快照，尝试匹配当前日历
        for i in snapshots.indices {
            var snapshot = snapshots[i]
            
            // 1️⃣ 精确匹配
            if let matched = currentCalendars.first(where: {
                $0.calendarIdentifier == snapshot.identifier
            }) {
                if snapshot.isHidden {
                    resolvedHiddenIdentifiers.insert(matched.calendarIdentifier)
                }
                continue
            }
            
            // 2️⃣ 模糊匹配（identifier 已失效）
            if let matched = fingerprintMap[snapshot.fingerprint] {
                print("🔄 日历迁移: '\(snapshot.calendarTitle)' " +
                      "ID从 \(snapshot.identifier.prefix(8))... → \(matched.calendarIdentifier.prefix(8))...")
                
                // 更新快照中的 identifier
                snapshot.identifier = matched.calendarIdentifier
                snapshots[i] = snapshot
                migrated = true
                
                if snapshot.isHidden {
                    resolvedHiddenIdentifiers.insert(matched.calendarIdentifier)
                }
            }
            // 3️⃣ 未匹配 → 日历已被删除，保留快照但不再处理
        }
        
        // 发现新日历（不在快照中的），默认显示
        for calendar in currentCalendars {
            let exists = snapshots.contains { $0.matches(calendar) }
            if !exists {
                let newSnapshot = CalendarSnapshot(
                    identifier: calendar.calendarIdentifier,
                    sourceTitle: calendar.source?.title ?? "",
                    calendarTitle: calendar.title,
                    isHidden: false  // 新日历默认显示
                )
                snapshots.append(newSnapshot)
                migrated = true
            }
        }
        
        // 如果发生了迁移或有新日历，持久化更新
        if migrated {
            saveSnapshots()
        }
        
        // 返回过滤结果
        return currentCalendars.filter {
            !resolvedHiddenIdentifiers.contains($0.calendarIdentifier)
        }
    }
    
    // MARK: - 用户操作接口
    
    /// 切换某个日历的显示/隐藏
    func toggleVisibility(for calendar: EKCalendar) {
        let id = calendar.calendarIdentifier
        if let index = snapshots.firstIndex(where: { $0.identifier == id }) {
            snapshots[index].isHidden.toggle()
        } else {
            // 首次记录
            snapshots.append(CalendarSnapshot(
                identifier: id,
                sourceTitle: calendar.source?.title ?? "",
                calendarTitle: calendar.title,
                isHidden: true
            ))
        }
        saveSnapshots()
    }
    
    /// 查询某日历当前是否隐藏
    func isHidden(_ calendar: EKCalendar) -> Bool {
        snapshots.first { $0.matches(calendar) }?.isHidden ?? false
    }
}

/// 日历身份快照，用于持久化存储
struct CalendarSnapshot: Codable, Equatable {
    var identifier: String          // 主键（可能失效）
    let sourceTitle: String         // 备份指纹1
    let calendarTitle: String       // 备份指纹2
    var isHidden: Bool              // 用户设置的显示/隐藏状态
    
    /// 生成语义指纹（用于模糊匹配）
    var fingerprint: String {
        "\(sourceTitle)::\(calendarTitle)"
    }
    
    /// 检查是否与当前日历匹配
    func matches(_ calendar: EKCalendar) -> Bool {
        // 精确匹配
        if calendar.calendarIdentifier == identifier { return true }
        // 模糊匹配
        let calFingerprint = "\(calendar.source?.title ?? "")::\(calendar.title)"
        return calFingerprint == fingerprint
    }
}
