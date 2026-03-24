//
//  FocusRecordListCellBaseInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/21.
//

import Foundation
import UIKit

/// 专注记录列表单元格基础信息视图（两种模式共用的基类）
class FocusRecordListCellBaseInfoView: UIView {
    
    /// 点击更多按钮回调
    var didClickMore: ((UIButton) -> Void)?
    
    /// 专注会话数据模型
    var session: FocusSession? {
        didSet {
            guard let session = session else {
                return
            }
            
            reloadData(with: session)
        }
    }

    /// 更多操作按钮尺寸
    let moreButtonSize = CGSize(width: 20.0, height: 20.0)
    
    /// 顶部高度
    let rangeLabelHeight: CGFloat = 36.0
    
    /// 信息视图高度
    let infoViewHeight: CGFloat = 15.0

    /// 日期范围标签
    lazy var dateRangeLabel: TPLabel = {
        let label = TPLabel()
        label.textAlignment = .left
        label.font = BOLD_BODY_FONT
        label.numberOfLines = 1
        label.textColor = resGetColor(.title)
        return label
    }()
    
    /// 计时器信息视图
    lazy var timerInfoView: TPImageTitleView = {
        let view = newInfoVIew()
        view.padding = UIEdgeInsets(right: 10.0)
        return view
    }()
    
    /// 任务信息视图
    lazy var taskInfoView: TPImageTitleView = {
        let view = newInfoVIew()
        view.image = resGetImage("bind_16")
        return view
    }()
    
    /// 更多操作按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.imageConfig.color = resGetColor(.title)
        button.addTarget(self, action: #selector(clickMore(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 设置UI组件
    private func setupUI() {
        self.addSubview(dateRangeLabel)
        self.addSubview(timerInfoView)
        self.addSubview(taskInfoView)
        self.addSubview(moreButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutComponents()
    }
    
    /// 布局子组件（子类可以重写）
    func layoutComponents() {
        let layoutFrame = layoutFrame()
        
        // 布局更多按钮
        moreButton.size = moreButtonSize
        moreButton.right = layoutFrame.maxX
        moreButton.centerY = layoutFrame.minY + rangeLabelHeight / 2.0
        
        // 布局日期范围标签
        dateRangeLabel.width = layoutFrame.width - moreButtonSize.width
        dateRangeLabel.height = rangeLabelHeight
        dateRangeLabel.origin = layoutFrame.origin

        // 布局计时器信息视图
        timerInfoView.width = layoutFrame.width / 2.0
        timerInfoView.height = infoViewHeight
        timerInfoView.top = dateRangeLabel.bottom
        timerInfoView.left = layoutFrame.minX
        
        taskInfoView.size = timerInfoView.size
        taskInfoView.top = timerInfoView.top
        taskInfoView.left = timerInfoView.right
    }
    
    /// 点击更多按钮事件处理
    /// - Parameter button: 按钮对象
    @objc private func clickMore(_ button: UIButton) {
        didClickMore?(button)
    }
    
    /// 根据专注会话数据重新加载界面内容
    /// - Parameter session: 专注会话数据模型
    func reloadData(with session: FocusSession) {
        dateRangeLabel.attributed.text = session.attributedDateRangeString()
        
        /// 计时器信息
        if let feature = session.timerFeature {
            timerInfoView.title = feature.timerInfo
        } else {
            timerInfoView.title = resGetString("Unknown Timer")
        }
        
        /// 任务信息
        if let feature = session.taskFeature{
            taskInfoView.title = feature.snapshotName ?? resGetString("Untitled task")
            taskInfoView.isHidden = false
        } else {
            /// 未绑定任务
            taskInfoView.title = resGetString("No task linked")
            taskInfoView.isHidden = true
        }
    }
    
    // MARK: - Helpers
    
    /// 创建计时器信息视图
    /// - Returns: TPImageTitleView实例
    private func newInfoVIew() -> TPImageTitleView {
        let color = resGetColor(.title)
        let view = TPImageTitleView()
        view.accessoryPosition = .left
        view.titleConfig.font = SMALL_SYSTEM_FONT
        view.titleConfig.textAlignment = .left
        view.imageConfig.margins = UIEdgeInsets(right: 2.0)
        view.imageConfig.size = .size(3)
        view.imageConfig.shouldRenderImageWithColor = true
        view.imageConfig.color = color
        view.titleConfig.textColor = color
        return view
    }
}
