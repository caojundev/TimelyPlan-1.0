//
//  Macros.swift
//  TimelyPlan
//
//  Created by caojun on 2023/4/6.
//

import Foundation
import UIKit

/// 时间常量
let SECONDS_PER_MINUTE = 60
let SECONDS_PER_HOUR = 3600
let SECONDS_PER_DAY = 86400
let HOURS_PER_DAY = 24
let MINUTES_PER_HOUR = 60
let DAYS_PER_WEEK = 7
let MONTHS_PER_YEAR = 12

/// 角度
let DEGREES_CIRCLE = 360.0
let DEGREES_HALF_CIRCLE = 180.0

/// 字体
let SMALL_SYSTEM_FONT = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
let SYSTEM_FONT = UIFont.systemFont(ofSize: UIFont.systemFontSize)
let BODY_FONT = UIFont.preferredFont(forTextStyle: .body)

let BOLD_SMALL_SYSTEM_FONT = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
let BOLD_SYSTEM_FONT = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
let BOLD_BODY_FONT = BODY_FONT.withBold()

// MARK: - 路径

/// 资源路径
let PATH_RESOURCE = Bundle.main.resourcePath

/// json 文件后缀
let JSON_FILE_EXTENSION = "json"
