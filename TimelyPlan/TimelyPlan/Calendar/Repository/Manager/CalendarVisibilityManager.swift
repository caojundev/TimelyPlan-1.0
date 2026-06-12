//
//  CalendarVisibilityManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/12.
//

import Foundation
import EventKit

/// 隐藏日历的身份快照（仅用于记录被隐藏的日历）
struct CalendarSnapshot: Codable, Equatable {
    var identifier: String          // 主键（可能失效）
    let sourceTitle: String         // 备份指纹1
    let calendarTitle: String       // 备份指纹2
    
    /// 生成语义指纹（用于模糊匹配）
    var fingerprint: String {
        "\(sourceTitle)::\(calendarTitle)"
    }
    
    /// 检查是否与当前日历匹配
    func matches(_ calendar: EKCalendar) -> Bool {
        // 精确匹配
        if calendar.calendarIdentifier == identifier { return true }
        // 模糊匹配（应对 ID 失效场景）
        let calFingerprint = "\(calendar.source?.title ?? "")::\(calendar.title)"
        return calFingerprint == fingerprint
    }
}

final class CalendarVisibilityManager {
    
    static let shared = CalendarVisibilityManager()
    
    private let hiddenSnapshotsKey = "hidden_calendar_snapshots_v2"
    /// 现在这个数组仅代表“被隐藏的日历”
    private var hiddenSnapshots: [CalendarSnapshot] = []
    
    private init() {
        loadSnapshots()
    }
    
    // MARK: - 持久化读写
    
    private func loadSnapshots() {
        hiddenSnapshots = CalendarSetting.shared.hiddenCalendars
    }
    
    private func saveSnapshots() {
        CalendarSetting.shared.hiddenCalendars = hiddenSnapshots
    }
    
    // MARK: - 核心：同步并解析可见性
    
    func resolveVisibleCalendars() {
        CalendarSystemManager.shared.fetchCalendars { result in
            if case .success(let calendars) = result {
                self.resolveVisibleCalendars(from: calendars)
            }
        }
    }
    
    /// 根据隐藏快照过滤出可见日历，同时修复失效的隐藏快照 ID
    /// - Parameter currentCalendars: 从 EKEventStore 获取的最新日历列表
    /// - Returns: 过滤后的可见日历数组
    @discardableResult
    func resolveVisibleCalendars(from currentCalendars: [EKCalendar]) -> [EKCalendar] {
        var migrated = false
        var resolvedHiddenIdentifiers: Set<String> = []
        
        // 构建当前日历的指纹索引，加速模糊查找
        let fingerprintMap: [String: EKCalendar] = Dictionary(
            uniqueKeysWithValues: currentCalendars.map {
                ("\($0.source?.title ?? "")::\($0.title)", $0)
            }
        )
        
        // 遍历已保存的隐藏快照，尝试匹配当前日历
        for i in hiddenSnapshots.indices {
            var snapshot = hiddenSnapshots[i]
            
            // 1️⃣ 精确匹配
            if let matched = currentCalendars.first(where: {
                $0.calendarIdentifier == snapshot.identifier
            }) {
                resolvedHiddenIdentifiers.insert(matched.calendarIdentifier)
                continue
            }
            
            // 2️⃣ 模糊匹配（identifier 已失效但日历仍存在）
            if let matched = fingerprintMap[snapshot.fingerprint] {
                print("🔄 隐藏日历迁移: '\(snapshot.calendarTitle)' " +
                      "ID从 \(snapshot.identifier.prefix(8))... → \(matched.calendarIdentifier.prefix(8))...")
                
                snapshot.identifier = matched.calendarIdentifier
                hiddenSnapshots[i] = snapshot
                migrated = true
                
                resolvedHiddenIdentifiers.insert(matched.calendarIdentifier)
            }
            // 3️⃣ 未匹配 → 该隐藏日历已被用户从系统中删除
            // 直接从隐藏列表中移除，避免垃圾数据堆积
            hiddenSnapshots.remove(at: i)
            migrated = true
        }
        
        // 如果发生了迁移或清理，持久化更新
        if migrated {
            saveSnapshots()
        }
        
        // 返回过滤结果：不在隐藏集合中的即为可见
        return currentCalendars.filter {
            !resolvedHiddenIdentifiers.contains($0.calendarIdentifier)
        }
    }
    
    // MARK: - 用户操作接口
    
    /// 切换某个日历的显示/隐藏
    func toggleVisibility(for calendar: EKCalendar) {
        if let index = hiddenSnapshots.firstIndex(where: { $0.matches(calendar) }) {
            // 当前已隐藏 → 取消隐藏 → 删除快照
            hiddenSnapshots.remove(at: index)
        } else {
            // 当前可见 → 设为隐藏 → 新增快照
            hiddenSnapshots.append(CalendarSnapshot(
                identifier: calendar.calendarIdentifier,
                sourceTitle: calendar.source?.title ?? "",
                calendarTitle: calendar.title
            ))
        }
        saveSnapshots()
    }
    
    /// 查询某日历当前是否隐藏
    func isHidden(_ calendar: EKCalendar) -> Bool {
        hiddenSnapshots.contains { $0.matches(calendar) }
    }
}
