//
//  MyDayFocusTimerBindCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/4.
//

import Foundation
import UIKit

class MyDayFocusTimerBindCell: TPDefaultInfoTableCell, SearchHighlightable {
    
    var timer: FocusTimer? {
        didSet {
            self.updateInfo()
        }
    }

    let kInfoViewMargin = 10.0
    
    let kIndicatorSize = CGSize(width: 6.0, height: 36.0)
    
    lazy var indicatorView: UIView = {
        let view = UIView()
        view.size = kIndicatorSize
        view.layer.cornerRadius = kIndicatorSize.width / 2.0
        return view
    }()
    
    /// 选中按钮
    private let checkboxSize = CGSize(width: 20.0, height: 20.0)
    private let checkboxMargins = UIEdgeInsets(right: 15.0)
    private(set) lazy var checkbox: TPCircularCheckbox = {
        let checkbox = TPCircularCheckbox()
        checkbox.isUserInteractionEnabled = false
        checkbox.padding = .zero
        checkbox.innerColor = resGetColor(.title)
        checkbox.outerColor = checkbox.innerColor
        return checkbox
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        titleConfig.textColor = .label
        subtitleConfig.textColor = .secondaryLabel
        rightView = checkbox
        rightViewSize = checkboxSize
        rightViewMargins = checkboxMargins
        contentView.padding = UIEdgeInsets(top: 5.0, left: 16.0, bottom: 5.0, right: 10.0)
        contentView.addSubview(indicatorView)
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        indicatorView.size = kIndicatorSize
        indicatorView.left = layoutFrame.minX
        indicatorView.alignVerticalCenter()
        
        infoView.width = layoutFrame.width - indicatorView.width - kInfoViewMargin
        infoView.height = layoutFrame.height
        infoView.left = indicatorView.right + kInfoViewMargin
        infoView.top = layoutFrame.minY
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkbox.setChecked(checked, animated: animated)
    }
    
    func updateInfo() {
        guard let timer = timer else {
            return
        }

        indicatorView.backgroundColor = timer.color
        
        if let timerName = timer.name,
            let highlightedText = highlightedText,
            highlightedText.count > 0  {
            /// 高亮文本
            let value = timerName.attributedStringWithHighlight(highlightedText,
                                                                normalAttributes: normalAttributes,
                                                                highlightAttributes: highlightAttributes)
            infoView.title = ASAttributedString(value: value)
        } else {
            infoView.title = timer.displayName
        }

        var subtitleComponents = [ASAttributedString]()
        if let timerDescription = timer.timerDescription {
            subtitleComponents.append(timerDescription.attributedString)
        }
        
        if timer.isAddedToMyDay, let myDayIndicator = timer.myDayIndicator(color: subtitleConfig.textColor) {
            subtitleComponents.append(myDayIndicator)
        }
        
        infoView.subtitle = subtitleComponents.joined(separator: " • ")
    }
    
    // MARK: - SearchHighlightable
    /// 高亮文本
    var highlightedText: String?
    
    /// 获取默认的正常文本属性
    var normalAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: titleConfig.textColor ?? .label,
            .font: titleConfig.font
        ]
    }
    
    /// 获取默认的高亮文本属性（黄色背景，黑色文字）
    var highlightAttributes: [NSAttributedString.Key: Any] {
        return [
            .backgroundColor: Color(0xFFD60A),
            .foregroundColor: UIColor.black,
            .font: titleConfig.font
        ]
    }
    
    /// 设置搜索文本并更新高亮显示
    func setHighlightedText(_ highlightedText: String?) {
        self.highlightedText = highlightedText
        self.updateInfo()
    }
}
