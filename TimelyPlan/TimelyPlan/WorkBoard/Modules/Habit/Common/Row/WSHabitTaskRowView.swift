//
//  WSHabitTaskRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

// MARK: - 行视图

/// 习惯任务行视图。
///
/// 展示内容与习惯列表一致：左侧图标（叠加进度圆环与状态角标），
/// 右侧任务名称与完成详情。整行响应点击，尺寸由外部决定。
class WSHabitTaskRowView: WSRowView {
    
    /// 布局尺寸。整体比习惯列表更紧凑，适配组件内的行高
    private enum Metrics {
        
        /// 内容与行边缘的间距
        static let contentInsets = UIEdgeInsets(left: 12.0, right: 4.0)
        
        /// 按下高亮的圆角
        static let cornerRadius: CGFloat = 10.0
        
        /// 图标边长
        static let iconSize: CGSize = .size(9)
        
        /// 进度圆环线宽
        static let progressLineWidth: CGFloat = 3.2
        
        /// 图标与文案的间距
        static let iconTitleSpacing: CGFloat = 8.0
        
        /// 标题字号
        static let titleFont = UIFont.boldSystemFont(ofSize: 14.0)
        
        /// 副标题字号
        static let subtitleFont = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        
        /// 标题与副标题的间距
        static let subtitleTopMargin: CGFloat = 2.0
        
        /// 骨架块颜色。组件底色偏亮，骨架块需要更明显的对比
        static let skeletonColor = Color(light: 0x000000, 0.12, dark: 0xFFFFFF, 0.22)
    }
    
    /// 任务信息视图，与习惯列表展示的内容一致
    private let infoView = HabitTaskProgressInfoView()
    
    /// 当前展示的习惯任务
    private(set) var dataItem: WSHabitTaskDataItem?
    
    /// 点击行的回调
    var didSelectTaskHandler: ((WSHabitTaskDataItem) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentCornerRadius = Metrics.cornerRadius
        infoView.padding = Metrics.contentInsets
        
        infoView.iconSize = Metrics.iconSize
        /// 进度圆环跟随图标一起缩小，否则线宽会盖住图标
        infoView.progressView.progressLineWidth = Metrics.progressLineWidth
        
        /// 文案配置与其它组件行保持一致：固定字号、单行、按宽度自适应缩放
        let titleView = infoView.titleView
        titleView.padding = UIEdgeInsets(left: Metrics.iconTitleSpacing)
        titleView.subtitleTopMargin = Metrics.subtitleTopMargin
        titleView.titleConfig = .withFont(Metrics.titleFont,
                                          textColor: .label,
                                          adjustsFontSizeToFitWidth: true,
                                          minimumScaleFactor: 0.7)
        
        let subtitleConfig = TPLabelConfig.withFont(Metrics.subtitleFont,
                                                    textColor: .secondaryLabel,
                                                    adjustsFontSizeToFitWidth: true,
                                                    minimumScaleFactor: 0.7)
        subtitleConfig.alpha = 0.8
        titleView.subtitleConfig = subtitleConfig
        
        /// 组件底色偏亮，骨架块需要更明显的对比
        var skeletonConfig = Skeleton.config
        skeletonConfig.baseColor = Metrics.skeletonColor
        self.skeletonConfig = skeletonConfig
        
        setupSkeleton()
        addSubview(infoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 骨架
    /// 标记骨架块：图标与两行文本；进度圆环与状态角标不参与骨架
    private func setupSkeleton() {
        infoView.iconView.isSkeletonable = true
        infoView.iconView.skeletonShape = .circle
        
        infoView.progressView.isSkeletonExcluded = true
        infoView.statusView.isSkeletonExcluded = true
        
        let titleView = infoView.titleView
        titleView.titleLabel.isSkeletonable = true
        titleView.titleLabel.skeletonShape = .capsule
        titleView.titleLabel.skeletonWidthRatio = 0.6
        
        titleView.subtitleLabel.isSkeletonable = true
        titleView.subtitleLabel.skeletonShape = .capsule
        titleView.subtitleLabel.skeletonWidthRatio = 0.45
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        infoView.frame = bounds
    }
    
    // MARK: - 交互
    /// 点击行。没有对应任务时（空白行）不响应
    override func didSelectRow() {
        guard let dataItem = dataItem else {
            return
        }
        
        didSelectTaskHandler?(dataItem)
    }
    
    // MARK: - 渲染
    /// 更新展示的习惯任务。传 nil 时清空内容并展示骨架
    func update(with dataItem: WSHabitTaskDataItem?) {
        self.dataItem = dataItem
        
        guard let dataItem = dataItem else {
            updateContent(icon: nil,
                          title: nil,
                          subtitle: nil,
                          color: nil,
                          progress: 0.0,
                          status: .notStarted)
            
            /// 骨架态保留标题 / 副标题一行高度，Skeleton 才能生成文本占位块
            infoView.titleView.titleMinimumHeight = ceil(infoView.titleView.titleConfig.font.lineHeight)
            infoView.titleView.subtitleMinimumHeight = ceil(infoView.titleView.subtitleConfig.font.lineHeight)
            
            setNeedsLayout()
            layoutIfNeeded()
            sk.show(config: skeletonConfig)
            return
        }
        
        sk.hide()
        infoView.titleView.titleMinimumHeight = 0.0
        infoView.titleView.subtitleMinimumHeight = 0.0
        
        updateContent(icon: dataItem.icon,
                      title: dataItem.title,
                      subtitle: dataItem.subtitle,
                      color: dataItem.color,
                      progress: dataItem.progress,
                      status: dataItem.status)
        setNeedsLayout()
    }
    
    /// 更新图标、进度、状态与文案。图标为空时视为加载态，隐藏进度与状态
    private func updateContent(icon: TPIcon?,
                               title: String?,
                               subtitle: TextRepresentable?,
                               color: UIColor?,
                               progress: CGFloat,
                               status: HabitTaskStatus) {
        let iconView = infoView.iconView
        iconView.icon = icon
        iconView.foreColor = icon == nil ? nil : Color(0xFFFFFF, 0.8)
        iconView.backColor = color
        
        infoView.progressView.progressLineColor = color?.lighterColor
        infoView.progressView.backLineColor = Color(0x000000, 0.2)
        
        let isShowingSkeleton = (icon == nil)
        infoView.progressView.isHidden = isShowingSkeleton
        infoView.statusView.isHidden = isShowingSkeleton
        
        infoView.setProgress(progress)
        infoView.setStatus(status)
        infoView.titleView.title = title
        infoView.titleView.subtitle = subtitle
    }
}
