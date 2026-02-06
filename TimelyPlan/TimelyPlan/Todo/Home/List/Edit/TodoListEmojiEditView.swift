//
//  TodoListEmojiEditView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/6.
//

import Foundation
import UIKit

class TodoListEmojiEditView: TPEmojiEditView {
    
    /// 占位图片颜色
    var foreColor: UIColor? = resGetColor(.title) {
        didSet {
            if foreColor != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 占位图片
    var placeholderImage: UIImage? {
        get {
            return placeholderImageView.image
        }
        
        set {
            if placeholderImageView.image != newValue {
                placeholderImageView.image = newValue
                setNeedsLayout()
            }
        }
    }

    /// 占位图片视图
    lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    /// 编辑工具栏，用于清除已输入 emoji
    lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        toolbar.tintColor = resGetColor(.title)
        
        let clearButtonItem = UIBarButtonItem(image: resGetImage("clear_24"),
                                   style: .done,
                                   target: self,
                                   action: #selector(clickClear))
        clearButtonItem.tintColor = .danger6
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
        toolbar.items = [flexibleSpace,
                         clearButtonItem]
        return toolbar
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textField.inputAccessoryView = toolbar
        self.normalBackgroundColor = .clear
        self.addSubview(placeholderImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderImageView.frame = layoutFrame()
        placeholderImageView.updateContentMode()
        placeholderImageView.updateImage(withColor: foreColor)
        label.textColor = foreColor
    }

    override func updateEmojiLabel() {
        if let emoji = emoji {
            placeholderImageView.isHidden = true
            label.isHidden = false
            label.text = String(emoji)
        } else {
            placeholderImageView.isHidden = false
            label.isHidden = true
            label.text = nil
        }
    }
    
    @objc func clickClear() {
        emoji = nil
        emojiDidChange?(nil)
    }
}
