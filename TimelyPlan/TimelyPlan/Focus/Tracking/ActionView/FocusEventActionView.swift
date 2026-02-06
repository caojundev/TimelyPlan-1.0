//
//  FocusEventActionView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/18.
//

import Foundation

class FocusEventActionView: TPToolbar {
    
    /// 选中事件动作回调
    var didSelectActionType: ((FocusEventActionType) -> Void)?
    
    /// 动作类型
    var actionTypes: [FocusEventActionType] = [] {
        didSet {
            if actionTypes != oldValue {
                setupButtonItems()
            }
        }
    }
    
    /// 按钮颜色
    var buttonColor = UIColor.primary {
        didSet {
            guard buttonColor != oldValue else {
                return
            }
            
            startButtonItem.color = buttonColor
            pauseButtonItem.color = buttonColor
            resumeButtonItem.color = buttonColor
            nextButtonItem.color = buttonColor
            updateButtonColor()
        }
    }
    
    /// 开始按钮
    lazy var startButtonItem: TPBarButtonItem = {
        let image = resGetImage("timer_start_24")
        let item = TPBarButtonItem(image: image, color: buttonColor) {[weak self] _ in
            self?.selectActionType(.start)
        }
        
        return item
    }()
    
    /// 暂停按钮
    lazy var pauseButtonItem: TPBarButtonItem = {
        let image = resGetImage("timer_pause_24")
        let item = TPBarButtonItem(image: image, color: buttonColor) {[weak self] _ in
            self?.selectActionType(.pause)
        }
        
        return item
    }()
    
    /// 继续按钮
    lazy var resumeButtonItem: TPBarButtonItem = {
        let image = resGetImage("timer_start_24")
        let item = TPBarButtonItem(image: image, color: buttonColor) {[weak self] _ in
            self?.selectActionType(.resume)
        }
        
        return item
    }()
    
    /// 下一步按钮
    lazy var nextButtonItem: TPBarButtonItem = {
        let image = resGetImage("timer_next_24")
        let item = TPBarButtonItem(image: image, color: buttonColor) {[weak self] _ in
            self?.selectActionType(.next)
        }
        
        return item
    }()
    
    private let leftFlexibleSpaceItem: TPBarButtonItem = .flexibleSpaceButtonItem
    private let rightFlexibleSpaceItem: TPBarButtonItem = .flexibleSpaceButtonItem
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.minimumItemWidth = 40.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButtonItems() {
        var buttonItems = [leftFlexibleSpaceItem]
        for actionType in actionTypes {
            switch actionType {
            case .start:
                buttonItems.append(startButtonItem)
            case .pause:
                buttonItems.append(pauseButtonItem)
            case .resume:
                buttonItems.append(resumeButtonItem)
            case .next:
                buttonItems.append(nextButtonItem)
            }
        }
        
        buttonItems.append(rightFlexibleSpaceItem)
        self.buttonItems = buttonItems
    }
    
    // MARK: - Event Response
    private func selectActionType(_ actionType: FocusEventActionType) {
        TPImpactFeedback.impactWithMediumStyle()
        didSelectActionType?(actionType)
    }
}
