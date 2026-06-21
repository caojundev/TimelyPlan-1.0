//
//  Bundle+Extension.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/21.
//

import Foundation

extension Bundle {
    /// 用户可见版本号 (CFBundleShortVersionString)
    var releaseVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    /// 内部构建号 (CFBundleVersion)
    var buildVersion: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    /// 组合版本字符串，如 "1.2.0 (42)"
    var fullVersion: String {
        "\(releaseVersion) (\(buildVersion))"
    }
}
