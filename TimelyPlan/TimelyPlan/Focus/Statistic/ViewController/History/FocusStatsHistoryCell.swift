//
//  FocusStatsHistoryCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/18.
//

import Foundation

class FocusStatsHistorySectionController: TPCollectionItemSectionController {
    
    /// 空白单元格条目
    lazy var emptyCellItem: TPDefaultInfoCollectionCellItem = {
        let cellItem = TPDefaultInfoCollectionCellItem()
        cellItem.title = resGetString("No History")
        cellItem.canHighlight = false
        cellItem.contentPadding = UIEdgeInsets(value: 16.0)
        cellItem.size = CGSize(width: .greatestFiniteMagnitude, height: 100.0)
        cellItem.titleConfig.font = .boldSystemFont(ofSize: 16.0)
        cellItem.titleConfig.textAlignment = .center
        cellItem.titleConfig.alpha = 0.5
        
        /// 自定义样式
        let style = TPCollectionCellStyle()
        style.cornerRadius = 16.0
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .secondarySystemFill
        cellItem.style = style
        return cellItem
    }()
    
    override init() {
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.headerItem.title = resGetString("History")
        self.headerItem.titleConfig.font = .boldSystemFont(ofSize: 16.0)
        self.headerItem.titleConfig.textColor = resGetColor(.title)
        self.headerItem.size = CGSize(width: .greatestFiniteMagnitude, height: 50.0)
        self.headerItem.padding = UIEdgeInsets(top: 20.0,
                                               left: 24.0,
                                               bottom: 0,
                                               right: 16.0)
        self.updateCellItems()
    }

    func updateCellItems() {
        /// 子类重写
    }
}


class FocusStatsHistoryCell: TPCollectionCell {
    
    private(set) lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.textColor = resGetColor(.title)
        return label
    }()

    let infoViewHeight = 80.0
    lazy var infoView: TPInfoGalleryView = {
        let view = TPInfoGalleryView(frame: .zero, infoViewsCount: 3)
        view[0].titleConfig.textAlignment = .left
        view[0].subtitleConfig.textAlignment = .left
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(infoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = contentView.layoutFrame()
        let labelWidth = layoutFrame.width
        headerLabel.width = labelWidth
        headerLabel.height = 30.0
        headerLabel.origin = layoutFrame.origin
        
        infoView.width = layoutFrame.width
        infoView.height = infoViewHeight
        infoView.left = layoutFrame.minX
        infoView.top = headerLabel.bottom
    }
}
