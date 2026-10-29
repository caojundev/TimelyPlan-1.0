//
//  WSGoalTaskDetailRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

// MARK: - 详情行视图

/// 目标任务详情行视图。
///
/// 在简略行基础上放大名称与进度尺寸，详情展示日期区间、进度与权重，
/// 与目标任务列表的详情保持一致，用于中 / 大尺寸列表。
class WSGoalTaskDetailRowView: WSGoalTaskBriefRowView {
    
    /// 布局尺寸。比简略行更宽松，容纳更完整的详情
    private enum Metrics {
        static let checkboxSize = CGSize.size(5)
        
        static let checkboxMargins = UIEdgeInsets(right: 8.0)
        
        /// 名称高度
        static let nameHeight: CGFloat = 20.0
        
        /// 名称与详情的间距
        static let detailTopMargin: CGFloat = 2.0
        
        /// 详情高度
        static let detailHeight: CGFloat = 16.0
        
        /// 详情与进度条的间距
        static let progressTopMargin: CGFloat = 4.0
        
        /// 进度条高度
        static let progressHeight: CGFloat = 4.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        infoView.checkboxSize = Metrics.checkboxSize
        infoView.checkboxMargins = Metrics.checkboxMargins
        infoView.nameHeight = Metrics.nameHeight
        infoView.detailTopMargin = Metrics.detailTopMargin
        infoView.detailHeight = Metrics.detailHeight
        infoView.progressTopMargin = Metrics.progressTopMargin
        infoView.progressHeight = Metrics.progressHeight
        infoView.nameLabel.font = .boldSystemFont(ofSize: 15.0)
        infoView.detailLabel.font = .systemFont(ofSize: 12.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 渲染
    /// 更新展示的目标任务。详情比简略行更完整：日期区间 • 进度 • 权重
    override func update(with dataItem: WSGoalTaskDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem else {
            return
        }
        
        infoView.attributedDetail = dataItem.attributedDetail
    }
}
