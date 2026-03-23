//
//  FocusSession.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/23.
//

import Foundation

class FocusSession: NSObject {

    var identifier: String
    
    var timerID: String?
    
    var duration: Int64
    
    var startDate: Date?
    
    var endDate: Date?
    
    var isManual: Bool
    
    var note: String?
    
    var score: Int64
    
    var taskID: String?
    
    var taskShotName: String?
    
    var taskType: Int64
    
    /// 计时器配置
    private(set) lazy var pauseInfo: FocusPauseInfo? = {
        if let json = pauseInfoJSON {
            return FocusPauseInfo.model(with: json)
        }
        
        return nil
    }()
    
    private var pauseInfoJSON: String?
    
    init(content: CDFocusSession) {
        self.identifier = content.identifier ?? UUID().uuidString
        self.timerID = content.timerID
        self.duration = content.duration
        self.startDate = content.startDate
        self.endDate = content.endDate
        self.isManual = content.isManual
        self.note = content.note
        self.score = content.score
        self.taskType = content.taskType
        self.taskID = content.taskID
        self.taskShotName = content.taskShotName
        self.pauseInfoJSON = content.pauseInfoJSON
        super.init()
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(timerID)
        hasher.combine(duration)
        hasher.combine(startDate)
        hasher.combine(endDate)
        hasher.combine(isManual)
        hasher.combine(note)
        hasher.combine(score)
        hasher.combine(taskID)
        hasher.combine(taskShotName)
        hasher.combine(taskType)
        hasher.combine(pauseInfoJSON)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? FocusSession else { return false }
        if self === other { return true }
        return identifier == other.identifier &&
            timerID == other.timerID &&
            duration == other.duration &&
            startDate == other.startDate &&
            endDate == other.endDate &&
            isManual == other.isManual &&
            note == other.note &&
            score == other.score &&
            taskID == other.taskID &&
            taskShotName == other.taskShotName &&
            taskType == other.taskType &&
            pauseInfoJSON == other.pauseInfoJSON
    }
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? FocusSession else { return false }
        if self === other { return true }
        /// 仅比较标识是否相同
        return identifier == other.identifier
    }
}
