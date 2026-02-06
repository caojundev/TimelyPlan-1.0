//
//  TFDescriptionTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/5.
//

import Foundation
import UIKit

class TPDescriptionTableCellLayout: TPBaseTableCellLayout {
    
    /// 标题
    var title: String? {
        didSet {
            if title != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 富文本标题
    var attributedTitle: ASAttributedString? {
        didSet {
            if attributedTitle != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 标题字体
    var titleFont: UIFont = BOLD_SYSTEM_FONT {
        didSet {
            if titleFont != oldValue {
                setNeedsLayout()
            }
        }
    }

    /// 标题行数
    var numberOfTitleLines: Int = 0 {
        didSet {
            if numberOfTitleLines != oldValue {
                setNeedsLayout()
            }
        }
    }

    override init() {
        super.init()
        self.minimumHeight = 36.0
        self.maximumHeight = .greatestFiniteMagnitude
    }
    
    override func getContentHeight() -> CGFloat {
        let constraintWidth = avaliableLayoutWidth()
        var string: Any?
        if let attributedTitle = attributedTitle {
            string = attributedTitle
        } else {
            string = title
        }
        
        let size: CGSize = .boundingSize(string: string,
                                         font: titleFont,
                                         constraintWidth: constraintWidth,
                                         linesCount: numberOfTitleLines)
        return size.height
    }
}

class TPDescriptionTableCellItem: TPBaseTableCellItem {
    
    /// 值文本
    var text: String?
    
    /// 富文本
    var attributedText: ASAttributedString?
    
    /// 字体
    var font = BOLD_SMALL_SYSTEM_FONT
    
    override init() {
        super.init()
        self.registerClass = TFDescriptionTableCell.self
        self.autoResizable = true
        self.contentPadding = UIEdgeInsets(horizontal: 16.0, vertical: 10.0)
        self.setLayout(TPDescriptionTableCellLayout())
        
        let cellStyle = TPTableCellStyle.defaultStyle()
        cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.style = cellStyle
    }
    
    override func getLayout() -> TPBaseTableCellLayout {
        let layout = super.getLayout() as! TPDescriptionTableCellLayout
        layout.title = text
        layout.attributedTitle = attributedText
        layout.titleFont = font
        layout.numberOfTitleLines = 0
        return layout
    }
}

class TFDescriptionTableCell: TPBaseTableCell {
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            updateDescription()
        }
    }

    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(descriptionLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        descriptionLabel.frame = contentView.layoutFrame()
    }
    
    func updateDescription() {
        guard let cellItem = cellItem as? TPDescriptionTableCellItem else {
            return
        }
        
        descriptionLabel.font = cellItem.font
        if let attributedText = cellItem.attributedText {
            descriptionLabel.text = nil
            descriptionLabel.attributed.text = attributedText
        } else {
            descriptionLabel.text = cellItem.text
        }
        
        setNeedsLayout()
    }

}
