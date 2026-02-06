//
//  TPEmojiView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/27.
//

import Foundation
import UIKit

class TPEmojiView: UIView {

    /// 占位表情字符
    var placeholderEmoji = Character.randomEmoji()
    
    /// 表情字符
    var emoji: Character? = nil {
        didSet {
            updateEmojiLabel()
        }
    }
    
    /// 显示字体
    var font: UIFont {
        get { return label.font }
        set { label.font = newValue }
    }
    
    /// 显示表情字符标签
    private(set) var label: UILabel!
    
    /// 圆角半径
    var cornerRadius: CGFloat = .greatestFiniteMagnitude
    
    /// 正常背景色
    var normalBackgroundColor: UIColor? {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        normalBackgroundColor = Color(0x888888, 0.1)
        
        label = UILabel(frame: self.bounds)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.font = .boldSystemFont(ofSize: 50.0)
        label.textAlignment = .center
        label.text = String(placeholderEmoji)
        addSubview(label)
        updateEmojiLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = normalBackgroundColor
        label.frame = layoutFrame()
        layer.cornerRadius = min(bounds.shortSideLength / 2.0, cornerRadius)
    }
    
    public func updateEmojiLabel() {
        if let emoji = emoji {
            label.text = String(emoji)
        } else {
            label.text = String(placeholderEmoji)
        }
    }
}
