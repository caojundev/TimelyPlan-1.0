//
//  TodoTaskQuickSendView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/23.
//

import Foundation
import UIKit
 
class TodoTaskQuickAddSendView: UIView {
    
    /// 任务所属列表
    var list: TodoList? {
        didSet {
            updateListPicker()
        }
    }

    /// 发送按钮是否可用
    var isSendEnabled: Bool = false {
        didSet {
            sendButton.isEnabled = isSendEnabled
        }
    }

    /// 选中清单回调
    var didSelectList: ((TodoList?) -> Void)?
    
    /// 点击发送按钮
    var didClickSend: ((UIButton) -> Void)?

    /// 列表选择按钮
    private lazy var listButton: TodoTaskQuickAddListPicker = {
        let button = TodoTaskQuickAddListPicker()
        button.didSelectList = { [weak self] list in
            guard let self = self else { return }
            self.list = list as? TodoList
            self.didSelectList?(self.list)
        }
        
        return button
    }()
    
    /// 发送按钮
    private let sendButtonSize: CGSize = .size(8)
    private lazy var sendButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.isEnabled = isSendEnabled
        button.padding = .zero
        button.size = sendButtonSize
        button.cornerRadius = .greatestFiniteMagnitude
        button.normalBackgroundColor = .primary
        button.imageConfig.color = Color(0xFFFFFF, 0.9)
        button.image = resGetImage("arrow_up_24")
        button.addTarget(self,
                         action: #selector(clickSend(_:)),
                         for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 10.0)
        self.addSeparator(position: .top)
        self.addSubview(self.listButton)
        self.addSubview(self.sendButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = self.layoutFrame()
        listButton.sizeToFit()
        listButton.width = min(layoutFrame.width / 2.0, listButton.width)
        listButton.left = layoutFrame.minX
        listButton.centerY = layoutFrame.midY
    
        sendButton.right = layoutFrame.maxX
        sendButton.alignVerticalCenter()
    }
    
    func updateListPicker() {
        if let list = list {
            listButton.list = list
        } else {
            listButton.list = TodoSmartList.inbox
        }
    }
    
    
    // MARK: - Event Response
    /// 点击完成
    @objc func clickSend(_ button: UIButton) {
        self.didClickSend?(button)
    }
}
