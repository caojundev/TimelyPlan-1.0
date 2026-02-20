//
//  FocusStatsInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/2.
//

import Foundation
import UIKit

struct FocusStatsInfo {
    
    /// 颜色
    var color: UIColor?
    
    /// 标题
    var title: String?
    
    /// 副标题
    var subtitle: String?
    
    /// 总专注时长
    var totalDuration: Duration?
}

class FocusStatsInfoView: UIView {
    
    var statsInfo: FocusStatsInfo? {
        didSet {
            indicatorView.backgroundColor = statsInfo?.color ?? .clear
            timerInfoView.title = statsInfo?.title
            timerInfoView.subtitle = statsInfo?.subtitle
            let totalDuration = statsInfo?.totalDuration ?? 0
            durationInfoView.title = totalDuration.attributedTitle()
            setNeedsLayout()
        }
    }
    
    private let indicatorMargin = 10.0
    
    private let indicatorSize = CGSize(width: 6.0, height: 36.0)
    
    private let durationInfoWidth = 120.0
    
    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.size = indicatorSize
        view.layer.cornerRadius = indicatorSize.width / 2.0
        view.backgroundColor = .clear
        return view
    }()
    
    /// 计时器信息视图
    private lazy var timerInfoView: TPInfoView = {
        let view = TPInfoView()
        view.titleConfig.font = UIFont.boldSystemFont(ofSize: 16.0)
        view.titleConfig.numberOfLines = 1
        return view
    }()
    
    /// 专注总时长信息视图
    lazy var durationInfoView: TPInfoView = {
        let textColor = resGetColor(.title)
        let view = TPInfoView()
        view.padding = UIEdgeInsets(horizontal: 2.0)
        view.titleConfig.adjustsFontSizeToFitWidth = true
        view.titleConfig.font = UIFont.boldSystemFont(ofSize: 16.0)
        view.titleConfig.textAlignment = .center
        view.titleConfig.textColor = textColor
        
        view.subtitleConfig.adjustsFontSizeToFitWidth = true
        view.subtitleConfig.textColor = textColor
        view.subtitleConfig.textAlignment = .center
        view.subtitleConfig.alpha = 0.5
        view.subtitleTopMargin = 10.0
        view.addSeparator(position: .left)
        view.separatorEdgeInset = UIEdgeInsets(vertical: 10.0)
        
        view.title = "---"
        view.subtitle = resGetString("Total Duration")
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func setupSubviews() {
        self.backgroundColor = .secondarySystemGroupedBackground
        self.padding = UIEdgeInsets(top: 10.0, left: 30.0, bottom: 10.0, right: 10.0)
        addSubview(indicatorView)
        addSubview(timerInfoView)
        addSubview(durationInfoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = self.layoutFrame()
        indicatorView.right = layoutFrame.minX - indicatorMargin
        indicatorView.alignVerticalCenter()

        durationInfoView.width = durationInfoWidth
        durationInfoView.height = layoutFrame.height
        durationInfoView.right = layoutFrame.maxX
        durationInfoView.top = layoutFrame.minY
        
        timerInfoView.width = layoutFrame.width - durationInfoView.width
        timerInfoView.height = layoutFrame.height
        timerInfoView.left = layoutFrame.minX
        timerInfoView.top = layoutFrame.minY
    }
}
