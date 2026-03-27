//
//  FocusDefaultTimerSelectSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/2.
//

import Foundation
import UIKit

class FocusDefaultTimerSelectSectionController: TPCollectionBaseSectionController {
    
    override var items: [ListDiffable]? {
        return focus.allDefaultTimers()
    }
    
    lazy var cellStyle: FocusUserTimerCellStyle = {
        let cellStyle = FocusUserTimerCellStyle()
        cellStyle.selectedBackgroundColor = cellStyle.backgroundColor
        return cellStyle
    }()
    
    lazy var layout: FocusTimerListSectionLayout = {
        let layout = FocusTimerListSectionLayout()
        layout.preferredItemWidth = .greatestFiniteMagnitude
        return layout
    }()
    
    override func interitemSpacing() -> CGFloat {
        return self.layout.interitemSpacing
    }
    
    override func lineSpacing() -> CGFloat {
        return self.layout.lineSpacing
    }
    
    override func sectionInset() -> UIEdgeInsets {
        return self.layout.sectionInset
    }
    
    // MARK: - Header
    override func layoutMarginsForHeaderFooterView(_ view: TPCollectionHeaderFooterView) -> UIEdgeInsets {
        var layoutMargins = layout.sectionInset
        layoutMargins.top = 0.0
        layoutMargins.left = 5.0
        layoutMargins.bottom = 0.0
        return layoutMargins
    }
    
    override func sizeForHeader() -> CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: 40.0)
    }
    
    override func classForHeader() -> AnyClass? {
        return TPCollectionHeaderFooterView.self
    }
    
    override func didDequeHeader(_ headerView: UICollectionReusableView) {
        if let headerView = headerView as? TPCollectionHeaderFooterView {
            headerView.delegate = self
            headerView.padding = UIEdgeInsets(top: 5.0, left: 0.0, bottom: 0, right: 15.0)
            headerView.titleConfig.font = .boldSystemFont(ofSize: 16.0)
            headerView.titleConfig.textColor = resGetColor(.title)
            headerView.title = resGetString("Default")
        }
    }

    override func sizeForItem(at index: Int) -> CGSize {
        self.layout.collectionViewSize = adapter?.collectionViewSize()
        return self.layout.constraintCellSize ?? .zero
    }
    
    override func classForCell(at index: Int) -> AnyClass? {
        return FocusDefaultTimerSelectCell.self
    }
    
    override func didDequeCell(_ cell: UICollectionViewCell, forItemAt index: Int) {
        super.didDequeCell(cell, forItemAt: index)
        let cell = cell as! FocusDefaultTimerSelectCell
        cell.timer = item(at: index) as? FocusSystemTimer
    }

    override func styleForItem(at index: Int) -> TPCollectionCellStyle? {
        return cellStyle
    }
}

class FocusDefaultTimerSelectCell: TPImageInfoCollectionCell {
    
    var timer: FocusSystemTimer? {
        didSet {
            self.updateInfo()
        }
    }
    
    lazy var checkmarkImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = resGetImage("checkmark_24")
        imageView.updateImage(withColor: .primary)
        return imageView
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.padding = UIEdgeInsets(top: 5.0, left: 8.0, bottom: 5.0, right: 10.0)
        infoView.rightAccessoryView = checkmarkImageView
        infoView.rightAccessorySize = .mini
        infoView.titleConfig.textAlignment = .left
        infoView.subtitleConfig.textAlignment = .left
        infoView.subtitleConfig.font = .systemFont(ofSize: 12.0)
        
        let imageConfig = TPImageAccessoryConfig()
        imageConfig.shouldRenderImageWithColor = false
        imageConfig.size = .size(8)
        self.imageConfig = imageConfig
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkmarkImageView.isHidden = !checked
    }

    func updateInfo() {
        var iconName: String?
        if let timerType = timer?.timerType {
            switch timerType {
            case .pomodoro:
                iconName = "focus_timer_bind_pomodoro_32"
            case .countdown:
                iconName = "focus_timer_bind_countdown_32"
            case .stopwatch:
                iconName = "focus_timer_bind_stopwatch_32"
            case .stepped:
                iconName = nil
            }
        }

        imageContent = .withName(iconName)
        infoView.title = timer?.timerType.title
        infoView.subtitle = timer?.timerDescription
    }
}
