//
//  FocusRecordListCellHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/30.
//

import Foundation
import UIKit

class FocusRecordListCellHeaderView: UIView {
    
    /// 点击更多按钮回调
    var didClickMore: ((UIButton) -> Void)?
    
    /// 专注会话
    var session: FocusSession? {
        didSet {
            guard let session = session else {
                return
            }
            
            reloadData(with: session)
        }
    }

    /// 日期范围标签
    lazy var dateRangeLabel: TPLabel = {
        let label = TPLabel()
        label.textAlignment = .left
        label.font = BOLD_BODY_FONT
        label.numberOfLines = 1
        label.textColor = resGetColor(.title)
        return label
    }()
    
    /// 标题标签
    lazy var timerInfoView: TPImageTitleView = {
        let view = newInfoVIew()
        view.padding = UIEdgeInsets(right: 10.0)
        return view
    }()
    
    let manualColor = UIColor.primary
    lazy var manualLabel: TPLabel = {
        let label = TPLabel()
        label.font = UIFont.boldSystemFont(ofSize: 8.0)
        label.textColor = manualColor
        label.layer.backgroundColor = manualColor.withAlphaComponent(0.2).cgColor
        label.layer.cornerRadius = 8.0
        label.text = resGetString("Manual")
        label.textAlignment = .center
        label.edgeInsets = UIEdgeInsets(horizontal: 6.0, vertical: 4.0)
        return label
    }()
    
    /// 更多按钮
    let moreButtonSize = CGSize(width: 20.0, height: 20.0)
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.imageConfig.color = resGetColor(.title)
        button.addTarget(self, action: #selector(clickMore(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 10.0, right: 0.0)
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
        let topHeight = 40.0
        let layoutFrame = layoutFrame()
        moreButton.size = moreButtonSize
        moreButton.right = layoutFrame.maxX
        moreButton.centerY = layoutFrame.minY + topHeight / 2.0
        
        manualLabel.sizeToFit()
        manualLabel.right = moreButton.left
        manualLabel.centerY = moreButton.centerY
        
        dateRangeLabel.width = layoutFrame.width - moreButtonSize.width - manualLabel.width
        dateRangeLabel.height = topHeight
        dateRangeLabel.origin = layoutFrame.origin

        let infoViewHeight = 15.0
        timerInfoView.width = layoutFrame.width / 2.0
        timerInfoView.height = infoViewHeight
        timerInfoView.top = dateRangeLabel.bottom
        timerInfoView.left = layoutFrame.minX
    }
    
    /// 点击更多
    @objc private func clickMore(_ button: UIButton) {
        didClickMore?(button)
    }
    
    private func setManulLabelHidden(_ isHidden: Bool) {
        manualLabel.isHidden = isHidden
    }
    
    private func reloadData(with session: FocusSession) {
        /// 时间范围
        dateRangeLabel.attributed.text = session.attributedDateRangeString()
        setManulLabelHidden(!session.isManual)
        
        /// 计时器信息
        let timerType = session.timerType
        timerInfoView.image = timerType.iconImage
        let timerName: String
        if let shotName = session.timerShotName {
            timerName = shotName
        } else {
            timerName = timerType.title
        }

        timerInfoView.title = timerName
    }
    
    // MARK: - Helpers
    private func newInfoVIew() -> TPImageTitleView {
        let color = resGetColor(.title)
        let view = TPImageTitleView()
        view.accessoryPosition = .left
        view.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        view.titleConfig.textAlignment = .left
        view.imageConfig.margins = UIEdgeInsets(right: 2.0)
        view.imageConfig.size = .size(4)
        view.imageConfig.shouldRenderImageWithColor = true
        view.imageConfig.color = color
        view.titleConfig.textColor = color
        return view
    }
}
