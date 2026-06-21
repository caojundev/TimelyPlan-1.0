//
//  AppConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/16.
//

import Foundation

struct AppConfig {
    
    /// 应用id
    static let appId = "6736433478"
    
    static var detailLink: String {
        return String(format: AppStoreLinks.appDetailFormat, appId)
    }
    
    static var reviewLink: String {
        return String(format: AppStoreLinks.writeReviewFormat, appId)
    }
    
    static var subscriptionLink: String {
        return String(format: AppStoreLinks.manageSubscriptions, appId)
    }
}

/// AppStore 相关链接管理
struct AppStoreLinks {
    
    /// 管理订阅页面链接
    static let manageSubscriptions = "https://apps.apple.com/account/subscriptions"
    
    /// App Store 应用详情链接格式
    static let appDetailFormat = "https://itunes.apple.com/app/id%@"
    
    /// 写评论链接格式
    static let writeReviewFormat = "https://itunes.apple.com/app/id%@?action=write-review"
}

/// 布局尺寸常量
struct AppLayout {
    
    /// 弹窗尺寸
    struct Popover {
        static let preferredContentWidth = 420.0
        static let preferredContentSize = CGSize(width: preferredContentWidth, height: 320.0)
    }
    
    /// 单元格
    struct Cell {
        /// 选项卡菜单圆角半径
        static let segmentedMenuCornerRadius = 14.0
    }
    
    /// 指示器
    struct Indicator {
        static let mediumSize = CGSize(width: 16.0, height: 16.0)
    }
}
