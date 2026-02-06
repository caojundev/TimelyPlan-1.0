//
//  FocusRecordCollectionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/7.
//

import Foundation
import UIKit

protocol FocusRecordListCellDelegate: AnyObject {
    
    /// 点击更多按钮
    func focusRecordListCell(_ cell: FocusRecordListCell, didClickMore button: UIButton)
}

class FocusRecordListCell: TPCollectionCell {

    var session: FocusSession? {
        didSet {
            update(with: session)
        }
    }
    
    /// 头视图
    var headerViewHeight = 70.0
    lazy var headerView: FocusRecordListCellHeaderView = {
        let view = FocusRecordListCellHeaderView()
        view.didClickMore = { [weak self] button in
            if let self = self,  let delegate = self.delegate as? FocusRecordListCellDelegate {
                delegate.focusRecordListCell(self, didClickMore: button)
            }
        }
        
        return view
    }()
    
    var infoViewHeight = 90.0
    lazy var infoView: TPInfoGalleryView = {
        let view = TPInfoGalleryView(frame: .zero, infoViewsCount: 3)
    
        view[0].padding = UIEdgeInsets(right: 10.0)
        view[0].titleConfig.textAlignment = .left
        view[0].subtitleConfig.textAlignment = .left
        view[0].subtitle = resGetString("Focus duration")
        
        view[1].subtitle = resGetString("Score")
        view[1].titleConfig.textAlignment = .center
        view[1].subtitleConfig.textAlignment = .center
    
        view[2].subtitle = resGetString("Pause")
        view[2].titleConfig.textAlignment = .center
        view[2].subtitleConfig.textAlignment = .center
        return view
    }()
    
    /// 备注标签
    private lazy var noteLabel: TPLabel = {
        let label = TPLabel()
        label.edgeInsets = UIEdgeInsets(horizontal: 10.0, vertical: 10.0)
        label.textAlignment = .left
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.numberOfLines = 0
        label.textColor = resGetColor(.title)
        return label
    }()

    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(headerView)
        contentView.addSubview(infoView)
        contentView.addSubview(noteLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.padding = UIEdgeInsets(horizontal: 16.0, vertical: 10.0)
        let layoutFrame = contentView.layoutFrame()
        headerView.width = layoutFrame.width
        headerView.height = headerViewHeight
        headerView.origin = layoutFrame.origin
        
        infoView.width = layoutFrame.width
        infoView.height = infoViewHeight
        infoView.top = headerView.bottom
        infoView.left = layoutFrame.minX
    
        noteLabel.width = layoutFrame.width
        noteLabel.height = layoutFrame.maxY - infoView.bottom
        noteLabel.top = infoView.bottom
        noteLabel.left = layoutFrame.minX
        noteLabel.layer.backgroundColor = Color(0xbbbbbb, 0.1).cgColor
        noteLabel.layer.cornerRadius = 8.0
    }
    
    private func update(with session: FocusSession?) {
        guard let session = session else {
            return
        }

        headerView.session = session
        infoView[0].title = Duration(session.duration).attributedTitle
        infoView[1].title = "\(session.score)"
        let pauseCount = session.pauses?.count ?? 0
        infoView[2].title = pauseCount > 0 ? "\(pauseCount)" : "--"
        
        /// 设置备注
        noteLabel.text = session.note
        setNeedsLayout()
    }
}
