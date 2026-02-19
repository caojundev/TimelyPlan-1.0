//
//  FocusRecordListCellHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/30.
//

import Foundation
import UIKit

/// 专注记录列表单元格头部视图
class FocusRecordListCellHeaderView: UIView {
    
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
    private let rangeLabelHeight: CGFloat = 36.0
    
    /// 信息视图高度
    private let infoViewHeight: CGFloat = 15.0

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
    
    /// 手动创建标识相关颜色
    private let manualColor: UIColor = .primary
    
    /// 手动创建标识标签
    private lazy var manualLabel: TPLabel = {
        let label = TPLabel()
        label.font = UIFont.systemFont(ofSize: 8.0)
        label.textColor = .white
        label.layer.backgroundColor = manualColor.cgColor
        label.text = resGetString("Manual")
        label.textAlignment = .center
        label.edgeInsets = UIEdgeInsets(horizontal: 6.0, vertical: 4.0)
        return label
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
        self.padding = UIEdgeInsets(top: 0.0,
                                    left: 0.0,
                                    bottom: 10.0,
                                    right: 0.0)
        self.addSubview(dateRangeLabel)
        self.addSubview(timerInfoView)
        self.addSubview(manualLabel)
        self.addSubview(moreButton)
        self.addSeparator(position: .bottom)
        setManulLabelHidden(true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        
        // 布局更多按钮
        moreButton.size = moreButtonSize
        moreButton.right = layoutFrame.maxX
        moreButton.centerY = layoutFrame.minY + rangeLabelHeight / 2.0
        
        // 布局手动标签
        manualLabel.sizeToFit()
        manualLabel.right = moreButton.left
        manualLabel.centerY = moreButton.centerY
        manualLabel.layer.cornerRadius = manualLabel.halfHeight
        
        // 布局日期范围标签
        dateRangeLabel.width = layoutFrame.width - moreButtonSize.width - manualLabel.width
        dateRangeLabel.height = rangeLabelHeight
        dateRangeLabel.origin = layoutFrame.origin

        // 布局计时器信息视图
        timerInfoView.width = layoutFrame.width / 2.0
        timerInfoView.height = infoViewHeight
        timerInfoView.top = dateRangeLabel.bottom
        timerInfoView.left = layoutFrame.minX
    }
    
    /// 点击更多按钮事件处理
    /// - Parameter button: 按钮对象
    @objc private func clickMore(_ button: UIButton) {
        didClickMore?(button)
    }
    
    /// 设置手动标签隐藏状态
    /// - Parameter isHidden: 是否隐藏
    private func setManulLabelHidden(_ isHidden: Bool) {
        manualLabel.isHidden = isHidden
    }
    
    /// 根据专注会话数据重新加载界面内容
    /// - Parameter session: 专注会话数据模型
    private func reloadData(with session: FocusSession) {
        dateRangeLabel.attributed.text = session.attributedDateRangeString()
        setManulLabelHidden(!session.isManual)
    
        /// 计时器信息
        let timer = session.timer
        let title: TextRepresentable
        if let timerInfo = timer?.timerInfo {
            title = timerInfo
        } else if let shotName = session.timerShotName {
            title = shotName
        } else {
            title = resGetString("No timer bound")
        }
        
        timerInfoView.title = title
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
