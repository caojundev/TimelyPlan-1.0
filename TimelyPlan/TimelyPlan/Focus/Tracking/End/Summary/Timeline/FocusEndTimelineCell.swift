//
//  FocusEndTimelineCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/19.
//

import Foundation
import UIKit

class FocusEndTimelineCellItem: TPCollectionCellItem {

    var dataItem: FocusEndDataItem?
    
    override init() {
        super.init()
        self.registerClass = FocusEndTimelineCell.self
        self.contentPadding = UIEdgeInsets(horizontal: 16.0, vertical: 15.0)
        self.canHighlight = false
        self.height = 260.0
    }
}

class FocusEndTimelineCell: TPCollectionCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            let cellItem = cellItem as! FocusEndTimelineCellItem
            updateInfo(with: cellItem.dataItem)
        }
    }
    
    lazy var wheatView: TPWheatView = {
        let wheatView = TPWheatView()
        let infoView = wheatView.infoView

        let textColor = resGetColor(.title)
        let titleConfig = infoView.titleConfig
        titleConfig.adjustsFontSizeToFitWidth = true
        titleConfig.font = UIFont.boldSystemFont(ofSize: 36.0)
        titleConfig.textAlignment = .center
        titleConfig.textColor = textColor
        
        let subtitleConfig = infoView.subtitleConfig
        subtitleConfig.adjustsFontSizeToFitWidth = true
        subtitleConfig.font = BOLD_SMALL_SYSTEM_FONT
        subtitleConfig.textAlignment = .center
        subtitleConfig.textColor = textColor
        subtitleConfig.alpha = 0.6
        infoView.subtitle = resGetString("Focus Duration")
        return wheatView
    }()
        
    lazy var trackView: FocusEndTimelineTrackView = {
        let view = FocusEndTimelineTrackView()
        return view
    }()
    
    lazy var infoView: TPInfoGalleryView = {
        let view = TPInfoGalleryView(frame: .zero, infoViewsCount: 3)
        view[0].subtitle = resGetString("Focus Rate")
        view[1].subtitle = resGetString("Pause Count")
        view[2].subtitle = resGetString("Pause Duration")
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(wheatView)
        contentView.addSubview(trackView)
        contentView.addSubview(infoView)
        updateWheatTitle(duration: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        
        wheatView.sizeToFit()
        wheatView.height = 80.0
        wheatView.top = layoutFrame.minY
        wheatView.alignHorizontalCenter()
        
        trackView.width = layoutFrame.width
        trackView.height = 60.0
        trackView.top = wheatView.bottom
        trackView.left = layoutFrame.minX
        
        infoView.width = layoutFrame.width
        infoView.height = 90.0
        infoView.top = trackView.bottom + 10.0
        infoView.left = layoutFrame.minX
    }
    
    func updateInfo(with dataItem: FocusEndDataItem?) {
        trackView.reloadData(with: dataItem)
        guard let dataItem = dataItem else {
            updateWheatTitle(duration: nil)
            infoView.resetTitle()
            return
        }

        /// 更新专注时长信息
        updateWheatTitle(duration: dataItem.focusDuration)
        /// 更新其它信息
        let focusRate = Float(dataItem.focusRate)
        infoView[0].title = focusRate.attributedPercentageString(decimalPlaces: 0)
        
        let pauseCount = dataItem.pauseCount
        if pauseCount > 0 {
            infoView[1].title = "\(dataItem.pauseCount)"
        } else {
            infoView[1].title = "--"
        }

        let pauseDuration = dataItem.pauseDuration
        if pauseDuration > 0 {
            infoView[2].title = dataItem.pauseDuration.attributedTitle()
        } else {
            infoView[2].title = "--"
        }
    }
    
    func updateWheatTitle(duration: Duration?) {
        let infoView = wheatView.infoView
        if let duration = duration {
            infoView.title = duration.attributedTitle()
        } else {
            infoView.title = "--"
        }
    }
}
