//
//  TPButtonActionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/23.
//

import Foundation

class TPButtonActionCell: TPImageTitleCollectionCell {
    
    private let isEnabledKeyPath = "isEnabled"
    
    /// 按钮动作
    var action: TPButtonAction? {
        didSet {
            // 移除之前的观察者
            oldValue?.removeObserver(self, forKeyPath: isEnabledKeyPath)
            action?.addObserver(self,
                                forKeyPath: isEnabledKeyPath,
                                options: [.initial, .new],
                                context: nil)
            
            update()
        }
    }
    
    func update() {
        guard let action = action else {
            return
        }
        
        padding = action.padding
        imageTitleView.accessoryPosition = action.imagePosition
        imageTitleView.title = action.title
        imageTitleView.image =  action.image
        
        let titleConfig = imageTitleView.titleConfig
        titleConfig.font = action.titleFont
        titleConfig.textAlignment = action.textAlignment
        titleConfig.textColor = action.titleColor
        titleConfig.highlightedTextColor = action.highlightedTitleColor
        
        let imageConfig = imageTitleView.imageConfig
        imageConfig.color = action.imageColor
        imageConfig.highlightedColor = action.highlightedImageColor
        setNeedsLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageTitleView.frame = layoutFrame()
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == isEnabledKeyPath {
            let isEnabled = action?.isEnabled ?? true
            isDisabled = !isEnabled
        }
    }
}
