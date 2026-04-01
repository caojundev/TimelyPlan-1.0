//
//  TodoUserListHomeCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/30.
//

import Foundation
import UIKit

protocol TodoUserListHomeCellDelegate: TPExpandDefaultInfoTableCellDelegate {
    
    /// 点击更多
    func TodoUserListHomeCellDidClickMore(_ cell: TodoUserListHomeCell)
}

class TodoUserListHomeCell: TodoUserListBaseCell {

    /// 更多按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.imageConfig.color = .secondaryLabel
        button.addTarget(self,
                         action: #selector(clickMore(_:)),
                         for: .touchUpInside)
        return button
    }()

    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.rightView = moreButton
        self.rightViewSize = .mini
    }
    
    override func didChangeExpandedStatus() {
        super.didChangeExpandedStatus()
        updateSubtitle()
    }
    
    // MARK: - Update
    override func updateListInfo() {
        super.updateListInfo()
        updateSubtitle()
        updateTaskCount()
        setNeedsLayout()
    }
    
    /// 更新任务数目
    func updateTaskCount() {
        iconInfoTextValueView.valueConfig = .valueText("0")
    }
    
    func updateSubtitle() {
        guard let list = list else {
            infoView.subtitle = nil
            return
        }

        if isExpanded {
            infoView.subtitle = nil
        } else {
            let sublistCount = list.allSubItemsCount
            guard sublistCount > 0 else {
                infoView.subtitle = nil
                return
            }
            
            var format: String
            if sublistCount > 1 {
                format = resGetString("%ld sublists")
            } else {
                format = resGetString("%ld sublist")
            }
            
            infoView.subtitle = String(format: format, sublistCount)
        }
    }
    
    // MARK: - Event Response
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        if let delegate = delegate as? TodoUserListHomeCellDelegate {
            delegate.TodoUserListHomeCellDidClickMore(self)
        }
    }
}

extension TodoUserListHomeCell: TPDragPreviewViewProviding {
    
    func dragPreviewView() -> UIView? {
        let padding = UIEdgeInsets(left: 10.0, right: 5.0)
        let previewWidth = infoView.width + padding.horizontalLength
        let previewHeight = infoView.height + padding.verticalLength
        let previewFrame = CGRect(x: 0.0, y: 0.0, width: previewWidth, height: previewHeight)
        let view = TodoUserListHomeCellPreviewView(frame: previewFrame)
        view.padding = padding
        view.infoView.titleConfig = iconInfoTextValueView.titleConfig
        view.infoView.subtitleConfig = iconInfoTextValueView.subtitleConfig
        view.infoView.iconConfig = iconInfoTextValueView.iconConfig
        view.infoView.title = iconInfoTextValueView.title
        view.infoView.subtitle = iconInfoTextValueView.subtitle
        return view
    }
    
    func beginPosition() -> CGPoint {
        return contentView.convert(infoView.center, toViewOrWindow: self)
    }
}

class TodoUserListHomeCellPreviewView: UIView {

    let infoView = TPIconInfoTextValueView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        self.addSubview(infoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.infoView.frame = layoutFrame()
    }
}
