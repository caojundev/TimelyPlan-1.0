//
//  HabitTaskBindCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/29.
//

import Foundation
import UIKit

class HabitTaskBindCell: HabitTaskListDefaultInfoCell,
                            SearchHighlightable {
    
    /// 高亮文本
    var highlightedText: String?
    
    var normalAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: titleView.titleConfig.textColor ?? .label,
            .font: titleView.titleConfig.font
        ]
    }

    var highlightAttributes: [NSAttributedString.Key: Any] {
        return [
            .backgroundColor: Color(0xFFD60A),
            .foregroundColor: UIColor.black,
            .font: titleView.titleConfig.font
        ]
    }
    
    var titleView: TPInfoView {
        return self.infoView.titleView
    }
    
    lazy var checkmarkImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = resGetImage("checkmark_24")
        imageView.updateImage(withColor: .primary)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.padding = UIEdgeInsets(top: 4.0, left: 12.0, bottom: 4.0, right: 8.0)
        self.coverView.isHidden = true
        self.shadowView.layer.shadowColor = Color(0x343434, 0.1).cgColor
        self.shadowView.layer.shadowOffset = CGSize(width:0, height: 0.0)
        let titleView = self.infoView.titleView
        titleView.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        titleView.rightAccessoryView = checkmarkImageView
        titleView.rightAccessorySize = .mini
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func shouldAddMoreButton() -> Bool {
        /// 不添加更多按钮
        return false
    }
    
    override func updateStyleWithColor(_ color: UIColor) {
        let titleColor = resGetColor(.title)
        let iconView = infoView.iconView
        iconView.foreColor = titleColor
        iconView.backColor = Color(0xcccccc, 0.1)

        let titleView = infoView.titleView
        titleView.titleConfig.textColor = titleColor
        titleView.subtitleConfig.textColor = .secondaryLabel
    }
    
    override func updateCellStyle() {
        super.updateCellStyle()
        backgroundView?.backgroundColor = .secondarySystemGroupedBackground
        selectedBackgroundView?.backgroundColor = .secondarySystemGroupedBackground
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        self.checkmarkImageView.isHidden = !checked
    }
    
    override func updateTaskInfo() {
        super.updateTaskInfo()
        if let taskName = self.habitTask?.name,
           let highlightedText = highlightedText,
            highlightedText.count > 0 {
            let value = taskName.attributedStringWithHighlight(highlightedText,
                                                                normalAttributes: normalAttributes,
                                                                highlightAttributes: highlightAttributes)
            self.titleView.title = ASAttributedString(value: value)
        }
    }

    /// 设置搜索文本并更新高亮显示
    func setHighlightedText(_ highlightedText: String?) {
        self.highlightedText = highlightedText
        self.updateTaskInfo()
    }
}
