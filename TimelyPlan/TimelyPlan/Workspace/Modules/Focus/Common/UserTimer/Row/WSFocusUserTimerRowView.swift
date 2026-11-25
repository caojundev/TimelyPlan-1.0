//
//  WSFocusUserTimerRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation
import UIKit

// MARK: - 行视图

/// 用户计时器行视图。
///
/// 承载一个 `WSFocusUserTimerInfoView`，提供卡片底色、圆角与内边距。
/// 行内只有开始按钮响应点击，卡片本身不做按下高亮；尺寸由外部决定。
class WSFocusUserTimerRowView: WSRowView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 卡片底色
        static let backColor = Color(light: 0x000000, 0.05, dark: 0xFFFFFF, 0.10)
        
        /// 卡片圆角
        static let cornerRadius: CGFloat = 12.0
        
        /// 卡片内边距
        static let contentInsets = UIEdgeInsets(left: 8.0, right: 6.0)
    }
    
    /// 计时器信息视图
    private let infoView = WSFocusUserTimerInfoView()
    
    /// 点击开始按钮回调
    var didClickStartHandler: ((WSFocusUserTimerDataItem) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        normalBackColor = Metrics.backColor
        contentCornerRadius = Metrics.cornerRadius
        infoView.padding = Metrics.contentInsets
        
        /// 行内只有开始按钮响应点击，卡片本身不做高亮
        isHighlightEnabled = false
        
        /// 卡片底色偏亮，骨架块需要更明显的对比
        var skeletonConfig = Skeleton.config
        skeletonConfig.baseColor = Color(light: 0x000000, 0.12, dark: 0xFFFFFF, 0.22)
        infoView.skeletonConfig = skeletonConfig
        
        infoView.didClickStartHandler = { [weak self] dataItem in
            self?.didClickStartHandler?(dataItem)
        }
        addSubview(infoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        infoView.frame = layoutFrame()
    }
    
    // MARK: - 渲染
    /// 更新展示的计时器。传 nil 时清空内容并展示骨架
    func update(with dataItem: WSFocusUserTimerDataItem?) {
        infoView.update(with: dataItem)
        setNeedsLayout()
    }
}
