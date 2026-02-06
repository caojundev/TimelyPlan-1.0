//
//  TodoFolderHomeCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/28.
//

import Foundation
import UIKit

protocol TodoFolderHomeCellDelegate: TPExpandImageInfoRightButtonTableCellDelegate {
    
    /// 点击更多按钮
    func todoFolderHomeCellDidClickMore(_ cell: TodoFolderHomeCell)
}

class TodoFolderHomeCell: TPExpandImageInfoRightButtonTableCell {
    
    /// 目录
    var folder: TodoFolder? {
        didSet {
            self.title = folder?.name
            updateFolderImage()
            updateSubtitle()
            setNeedsLayout()
        }
    }

    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.padding = UIEdgeInsets(left: 5.0, right: 10.0)
        infoView.titleConfig.lineBreakMode = .byTruncatingMiddle
        infoView.subtitleConfig.font = UIFont.boldSystemFont(ofSize: 8.0)
        infoView.subtitleConfig.alpha = 0.6
        rightButton.imageConfig.color = .secondaryLabel
        rightButton.image = resGetImage("ellipsis_vertical_24")
    }
    
    override func didChangeExpandedStatus() {
        updateFolderImage()
        updateSubtitle()
    }

    override func clickRightButton(_ button: UIButton) {
        if let delegate = delegate as? TodoFolderHomeCellDelegate {
            delegate.todoFolderHomeCellDidClickMore(self)
        }
    }
    
    // MARK: - Update
    func updateFolderImage() {
        if isExpanded {
            imageInfoView.imageName = "todo_folder_opened_24"
        } else {
            imageInfoView.imageName = "todo_folder_24"
        }
    }
    
    func updateSubtitle() {
        if isExpanded {
            infoView.subtitle = nil
        } else {
            let count = folder?.lists?.count ?? 0
            guard count > 0 else {
                infoView.subtitle = nil
                return
            }
            
            var format: String
            if count > 1 {
                format = resGetString("%ld lists")
            } else {
                format = resGetString("%ld list")
            }
            
            infoView.subtitle = String(format: format, count)
        }
    }
}
