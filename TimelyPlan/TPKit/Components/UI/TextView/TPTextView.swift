//
//  TPTextView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/27.
//

import Foundation
import UIKit

class TPTextView: UITextView {
    
    override var text: String! {
        didSet {
            if text != oldValue {
                updatePlaceholderLabelAlpha()
                checkMaxCount()
            }
        }
    }

    /// 输入最大字符数目
    var maxCount: Int?
    
    /// 输入超出限制是否提示
    var isPromptWhenExceedLimit: Bool = true
    
    /// 占位文本位置
    enum PlaceholderPosition {
        case topLeft
        case center
    }

    var placeholderPosition: PlaceholderPosition = .topLeft
    
    var placeholder: String? {
        didSet {
            setNeedsLayout()
        }
    }
    
    var placeholderColor: UIColor = .lightGray {
        didSet {
            setNeedsLayout()
        }
    }
    
    lazy var dismissToolbar: UIToolbar = {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        let toolbar = UIToolbar(frame: frame)
        toolbar.tintColor = resGetColor(.title)
        let image = resGetImage("keyboard_dismiss_24")
        let clearButton = UIBarButtonItem(image: image,
                                          style: .done,
                                          target: self,
                                          action: #selector(clickDismiss(_:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
        toolbar.items = [flexibleSpace, clearButton]
        return toolbar
    }()

    private lazy var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.alpha = 0
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        addSubview(placeHolderLabel)
        sendSubviewToBack(placeHolderLabel)
        addNotification()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeNotification()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updatePlaceholderLabelAlpha()
        placeHolderLabel.font = font
        placeHolderLabel.text = placeholder
        placeHolderLabel.textColor = placeholderColor
        
        /// 位置
        let insets = textContainerInset
        let layoutFrame = bounds.inset(by: insets)
        if placeholderPosition == .center {
            placeHolderLabel.frame = layoutFrame
            placeHolderLabel.textAlignment = .center
        } else if placeholderPosition == .topLeft {
            let labelMargin: CGFloat = 5.0
            let placeHolderLabelWidth = bounds.size.width - insets.horizontalLength - labelMargin
            let size = placeHolderLabel.sizeThatFits(CGSize(width: placeHolderLabelWidth, height: .greatestFiniteMagnitude))
            let placeHolderLabelRect = CGRect(x: insets.left + labelMargin,
                                               y: insets.top,
                                               size: size)
            placeHolderLabel.frame = placeHolderLabelRect
        }
    }
    
    // Notification
    func addNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textChanged(notification:)),
                                               name: UITextView.textDidChangeNotification,
                                               object: nil)
    }
    
    func removeNotification() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func textChanged(notification: Notification?) {
        updatePlaceholderLabelAlpha()
        checkMaxCount()
    }
    
    private func checkMaxCount() {
        guard let maxCount = maxCount else {
            return
        }

        if text.count > maxCount {
           // 如果输入的字符数超过最大长度，截取前maxCount个字符
            self.text = String(text.prefix(maxCount))
            
            /// 提示用户输入超过限制
            if isPromptWhenExceedLimit, self.isFirstResponder, !TPFeedbackQueue.common.isShowing {
                let format = resGetString("You have exceeded the maximum character limit of %ld.")
                let message = String(format: format, maxCount)
                TPFeedbackQueue.common.postFeedback(text: message, position: .middle)
            }
        }
    }
    
    private func updatePlaceholderLabelAlpha() {
        if text.isEmpty {
            placeHolderLabel.alpha = 1.0
        } else {
            placeHolderLabel.alpha = 0
        }
    }
    
    @objc private func clickDismiss(_ button: UIButton) {
        self.resignFirstResponder()
    }
    
}
