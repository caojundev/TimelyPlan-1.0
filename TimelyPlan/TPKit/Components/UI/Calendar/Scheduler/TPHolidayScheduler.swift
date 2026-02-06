//
//  TPHolidayScheduler.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/27.
//

import Foundation

enum TPDateState: Int, Decodable {

    case inNormal = 0
    case inWorking = 1
    case onHoliday = 2
    
    var title: String? {
        switch self {
        case .inWorking:
            return "班"
        case .onHoliday:
            return "休"
        default:
            return nil
        }
    }
}

class TPHolidayScheduler {
    
    /// 日期状态字典别名
    typealias TPDateStatesDic = [String: [String: TPDateState]]
    
    /// 中文节假日文件名称
    private let chinaHolidayFileName = "ChinaHoliday"
    
    /// 日期状态字典
    private var dateStatesDic: TPDateStatesDic
    
    /// 共享管理对象
    static let shared = TPHolidayScheduler()

    private init() {
        var jsonData: Data?
        if let path = Bundle.main.path(forResource: chinaHolidayFileName, ofType: JSON_FILE_EXTENSION) {
            let url = URL(fileURLWithPath: path)
            jsonData = try? Data(contentsOf: url)
        }
        
        if let jsonData = jsonData {
            self.dateStatesDic = TPDateStatesDic.model(with: jsonData) ?? [:]
        } else {
            self.dateStatesDic = [:]
        }
    }
    
    /// 获取特定日期对应的状态
    func state(for date: Date) -> TPDateState {
        let yearKey = "\(date.year)"
        guard let dic = dateStatesDic[yearKey] else {
            return .inNormal
        }
        
        let monthDayKey = String(format: "%02ld%02ld", date.month, date.day)
        return dic[monthDayKey] ?? .inNormal
    }
}
