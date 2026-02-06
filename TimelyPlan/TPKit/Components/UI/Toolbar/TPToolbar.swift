//
//  TPToolbar.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/4.
//

import Foundation
import UIKit

class TPToolbar: UIView {
    
    /// 最小条目宽度
    var minimumItemWidth: CGFloat = 30.0
    
    /// 最大条目宽度
    var maximumItemWidth: CGFloat = .greatestFiniteMagnitude
    
    /// 按钮条目
    var buttonItems: [TPBarButtonItem]? {
        didSet {
            guard buttonItems != oldValue else {
                return
            }
            
            setupButtons(oldButtonItems: oldValue, newButtonItems: buttonItems)
        }
    }

    fileprivate var buttons: [TPToolbarButton] = []
    
    fileprivate var buttonDic: [TPBarButtonItem: TPToolbarButton] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 20.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        var contentWidth: CGFloat = 0.0
        var flexibleSpaceCount = 0 /// 空白数目
        for button in buttons {
            if button.buttonItem.style == .flexibleSpace {
                flexibleSpaceCount += 1
            } else {
                let constraintSize = CGSize(width: .greatestFiniteMagnitude, height: height)
                let fitButtonSize = button.sizeThatFits(constraintSize)
                let buttonWidth = min(max(minimumItemWidth, fitButtonSize.width), maximumItemWidth)
                button.width = buttonWidth
                contentWidth += buttonWidth
            }
        }
        
        let flexibleSpaceWidth: CGFloat
        if flexibleSpaceCount == 0 {
            flexibleSpaceWidth = 0.0
        } else {
            flexibleSpaceWidth = (layoutFrame.width - contentWidth) / CGFloat(flexibleSpaceCount)
        }

        var left = layoutFrame.minX
        for button in buttons {
            if button.buttonItem.style == .flexibleSpace {
                button.width = flexibleSpaceWidth
            }
            
            button.left = left
            button.height = layoutFrame.height
            left += button.width
        }
    }
    
    private func setupButtons(oldButtonItems: [TPBarButtonItem]?, newButtonItems: [TPBarButtonItem]?) {
        let oldButtonItems = oldButtonItems ?? []
        let newButtonItems = newButtonItems ?? []
        let removeButtonItems = oldButtonItems.filter{ !newButtonItems.contains($0) }
        for removeButtonItem in removeButtonItems {
            buttonDic[removeButtonItem]?.removeFromSuperview()
            buttonDic.removeValue(forKey: removeButtonItem)
        }
        
        var buttons = [TPToolbarButton]()
        for buttonItem in newButtonItems {
            if let button = buttonDic[buttonItem] {
                button.updateButtonColor() /// 更新按钮颜色
                buttons.append(button)
                if button.superview == nil {
                    addSubview(button)
                }
            } else {
                let button = TPToolbarButton(buttonItem: buttonItem)
                buttons.append(button)
                addSubview(button)
                buttonDic[buttonItem] = button
            }
        }
        
        self.buttons = buttons
        setNeedsLayout()
    }
    
    /// 更新按钮颜色
    func updateButtonColor() {
        for button in buttons {
            button.updateButtonColor()
        }
    }
    
}
