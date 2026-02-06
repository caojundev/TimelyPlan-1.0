//
//  FocusStatsInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/2.
//

import Foundation
import UIKit

struct FocusStatsInfo {
    
    var color: UIColor?
    
    var title: String?
    
    var subtitle: String?
}

class FocusStatsInfoView: UIView {
    
    var statsInfo: FocusStatsInfo? {
        didSet {
            indicatorView.backgroundColor = statsInfo?.color ?? .clear
            infoView.title = statsInfo?.title
            infoView.subtitle = statsInfo?.subtitle
            setNeedsLayout()
        }
    }
    
    let kInfoViewMargin = 10.0
    
    let kIndicatorSize = CGSize(width: 6.0, height: 36.0)
    
    lazy var indicatorView: UIView = {
        let view = UIView()
        view.size = kIndicatorSize
        view.layer.cornerRadius = kIndicatorSize.width / 2.0
        view.backgroundColor = .clear
        return view
    }()
    
    /// 信息视图
    lazy var infoView: TPInfoView = {
        let view = TPInfoView()
        view.titleConfig.font = UIFont.boldSystemFont(ofSize: 18.0)
        view.titleConfig.numberOfLines = 1
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
        self.backgroundColor = resGetColor(.insetGroupedTableCellBackgroundNormal)
        self.padding = UIEdgeInsets(horizontal: 16.0, vertical: 10.0)
        addSubview(indicatorView)
        addSubview(infoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = self.layoutFrame()
        indicatorView.size = kIndicatorSize
        indicatorView.left = layoutFrame.minX
        indicatorView.alignVerticalCenter()
        
        infoView.width = layoutFrame.width - indicatorView.width - kInfoViewMargin
        infoView.height = layoutFrame.height
        infoView.left = indicatorView.right + kInfoViewMargin
        infoView.top = layoutFrame.minY
    }
}
