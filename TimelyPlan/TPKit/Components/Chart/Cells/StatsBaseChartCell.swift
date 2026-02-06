//
//  StatsBaseChartCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/12.
//

import Foundation
import UIKit

class StatsBaseChartCellItem: TPCollectionCellItem {
    /// 头视图是否隐藏
    var isHeaderHidden: Bool = false
    
    /// 头标题
    var headerTitle: String?
    var headerAttributedTitle: ASAttributedString?
    
    /// 头副标题
    var headerSubtitle: String?
    var headerAttributedSubtitle: ASAttributedString?

    /// 头视图高度
    var headerHeight: CGFloat = 50.0
    var headerPadding: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 10.0, right: 16.0)
    
    /// 占位文本
    var placeholder: String?
    
    override init() {
        super.init()
        self.registerClass = StatsBaseChartCell.self
        self.canHighlight = false
        self.contentPadding = UIEdgeInsets(horizontal: 5.0, vertical: 10.0)
        self.size = CGSize(width: .greatestFiniteMagnitude, height: 320.0)
    }
}

class StatsBaseChartCell: TPCollectionCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            reloadData()
            setNeedsLayout()
        }
    }
    
    /// 头视图是否隐藏
    var isHeaderHidden: Bool = false {
        didSet {
            headerView.isHidden = isHeaderHidden
        }
    }
    
    var headerHeight: CGFloat = 60.0
    
    lazy var headerView: TPInfoView = {
       let view = TPInfoView()
        view.clipsToBounds = true
        view.titleConfig.font = BOLD_SYSTEM_FONT
        view.titleConfig.textColor = resGetColor(.title)
        view.subtitleConfig.font = UIFont.systemFont(ofSize: 12.0)
        view.subtitleConfig.textColor = .secondaryLabel
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(headerView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        headerView.width = layoutFrame.width
        headerView.height = headerHeight
        headerView.origin = layoutFrame.origin
        headerView.isHidden = isHeaderHidden
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            reloadData()
        }
    }
    
    func chartLayoutFrame() -> CGRect {
        let layoutFrame = contentView.layoutFrame()
        let headerHeight = isHeaderHidden ? 0.0 : headerHeight
        return CGRect(x: layoutFrame.minX,
                      y: layoutFrame.minY + headerHeight,
                      width: layoutFrame.width,
                      height: layoutFrame.height - headerHeight)
    }
    
    private func reloadData() {
        guard let cellItem = cellItem as? StatsBaseChartCellItem else {
            headerView.title = nil
            headerView.subtitle = nil
            return
        }
        
        headerHeight = cellItem.headerHeight
        isHeaderHidden = cellItem.isHeaderHidden
        headerView.padding = cellItem.headerPadding
        if let attributedTitle = cellItem.headerAttributedTitle {
            headerView.title = attributedTitle
        } else {
            headerView.title = cellItem.headerTitle
        }
        
        if let attributedSubtitle = cellItem.headerAttributedSubtitle {
            headerView.subtitle = attributedSubtitle
        } else {
            headerView.subtitle = cellItem.headerSubtitle
        }
    }
}
