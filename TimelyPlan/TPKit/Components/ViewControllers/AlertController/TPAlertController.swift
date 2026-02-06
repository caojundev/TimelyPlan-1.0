//
//  TPAlertController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/27.
//

import Foundation
import UIKit

class TPAlertController : TPViewController {
    
    let padding: UIEdgeInsets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    let itemMargin = 15.0
    
    enum Style {
        case alert
        case actionSheet
    }
    
    /// 弹出样式
    var style: Style = .alert

    var alertTitle: String?
    var alertMessage: String?
    var actions: [TPAlertAction] = []
    
    /// 附加视图
    var additionalView: UIView?
    
    /// 附加视图尺寸
    var additionalSize: CGSize = .zero
    
    /// 标题标签
    private var titleLabel: UILabel!
    
    /// 描述标签
    private var messageLabel: UILabel!
    
    private var actionsView: TPButtonActionsView!
    
    lazy var cancelAlertAction: TPAlertAction = {
        let action = TPAlertAction(type: .cancel, title: resGetString("Cancel"))
        return action
    }()

    lazy var deleteAlertAction: TPAlertAction = {
        let action = TPAlertAction(type: .destructive, title: resGetString("Delete")) 
        return action
    }()
    
    lazy var doneAlertAction: TPAlertAction = {
        let action = TPAlertAction(title: resGetString("Confirm")) { [weak self] action in
            self?.clickDone()
        }
        
        return action
    }()
    
    convenience init(title: String?, message: String?) {
        self.init(title: title, message: message, style: .alert, actions: nil)
    }
    
    convenience init(title: String?, message: String?, actions: [TPAlertAction]?) {
        self.init(title: title, message: message, style: .alert, actions: actions)
    }
    
    init(title: String?, message: String?, style: Style, actions: [TPAlertAction]?) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.alertMessage = message
        self.style = style
        
        if let actions = actions, actions.count > 0 {
            self.actions = actions
        } else {
            self.actions = [cancelAlertAction, doneAlertAction]
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline).withBold()
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.text = alertTitle
        titleLabel.alpha = 0.8
        view.addSubview(titleLabel)
        
        messageLabel = UILabel()
        messageLabel.font = UIFont.systemFont(ofSize: 13.0)
        messageLabel.textAlignment = .center
        messageLabel.lineBreakMode = .byTruncatingMiddle
        messageLabel.numberOfLines = 4
        messageLabel.alpha = 0.6
        messageLabel.text = alertMessage
        view.addSubview(messageLabel)
    
        if let additionalView = additionalView {
            view.addSubview(additionalView)
        }
        
        actionsView = TPButtonActionsView(actions: actions)
        actionsView.actionsCountPerRow = style == .actionSheet ? 1 : 2
        actionsView.didSelectAction = { [weak self] action in
            self?.didSelectAction(action as! TPAlertAction)
        }
        
        actionsView.itemHeight = 50.0
        view.addSubview(actionsView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.bounds.inset(by: padding)
        var top = layoutFrame.minY
        
        if titleLabel.text != nil {
            let size = titleLabel.sizeThatFits(layoutFrame.size)
            titleLabel.size = size
            titleLabel.top = top
            titleLabel.centerX = layoutFrame.midX
            top += size.height + itemMargin
        }
        
        if messageLabel.text != nil {
            let size = messageLabel.sizeThatFits(layoutFrame.size)
            
            messageLabel.size = size
            messageLabel.top = top
            messageLabel.centerX = layoutFrame.midX
            top += size.height + itemMargin
        }
        
        if let additionalView = additionalView {
            var size = additionalSize
            if size.width > layoutFrame.width {
                size.width = layoutFrame.width
            }
            
            additionalView.size = size
            additionalView.top = top
            additionalView.centerX = layoutFrame.midX
            top += additionalSize.height + itemMargin
        }
        
        actionsView.width = layoutFrame.width
        actionsView.height = max(actionsView.itemHeight, actionsView.contentSize.height)
        actionsView.top = top
        actionsView.left = layoutFrame.minX
        setContentSize(contentSize())
    }
    
    func contentSize() -> CGSize {
        let layoutFrame = view.bounds.inset(by: padding)
        var height = padding.top
        if titleLabel.text != nil {
            let titleSize = titleLabel.sizeThatFits(layoutFrame.size)
            height += titleSize.height + itemMargin;
        }

        if messageLabel.text != nil {
            let messageSize = messageLabel.sizeThatFits(layoutFrame.size)
            height += messageSize.height + itemMargin
        }
        
        if additionalView != nil {
            height += additionalSize.height + itemMargin
        }
        
        height += actionsView.contentSize.height
        height += padding.bottom
        return CGSize(width: 380.0, height: height)
    }    
    
    func didSelectAction(_ action: TPAlertAction) {
        if action.handleBeforeDismiss {
            action.handler?(action)
            dismiss()
        } else {
            dismiss(animated: true) {
                action.handler?(action)
            }
        }
    }
    
    override func show(animated: Bool = true, completion: (() -> Void)? = nil) {
        if style == .alert {
            popoverShow()
        } else {
            slideShow(from: .bottom, animated: animated, completion: nil)
        }
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}


