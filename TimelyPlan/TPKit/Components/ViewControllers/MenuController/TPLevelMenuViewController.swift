//
//  TPLevelMenuViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation

class TPLevelMenuViewController: TPViewController {
    
    /// 选中菜单动作回调
    var didSelectMenuAction: ((TPMenuAction) -> Void)?
    
    /// 菜单宽度
    var menuContentWidth: CGFloat = 240.0
    
    /// 首选位置
    var preferredPosition: TPPopoverPosition = .bottomLeft
    
    /// 允许位置
    var permittedPositions: [TPPopoverPosition] = [.bottomLeft,
                                                 .bottomRight,
                                                 .topLeft,
                                                 .topRight]
    
    /// 菜单内容最大高度
    private let maxMenuContentHeight: CGFloat = 520.0
    
    /// 列表视图
    private var listView = TPMenuListView()
    
    /// 当前的菜单条目
    private var menuItems: [TPMenuItem]
    
    init(menuItems: [TPMenuItem]) {
        self.menuItems = menuItems
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(listView)
        self.listView.didSelectMenuAction = { [weak self] action in
            self?.selectMenuAction(action)
        }
        
        self.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
        updatePopoverContentSize()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .secondarySystemGroupedBackground
    }
    
    override var popoverContentSize: CGSize {
        var contentSize = listView.contentSize
        contentSize.width = menuContentWidth
        contentSize.height = clampedValue(contentSize.height,
                                          100.0,
                                          maxMenuContentHeight)
        return contentSize
    }
    
    func reloadData(animated: Bool = false) {
        self.listView.menuItems = self.menuItems
        let style: SlideStyle = animated ? .rightToLeft : .none
        self.listView.reloadData(animateStyle: style)
    }
    
    public func selectMenuAction(_ action: TPMenuAction) {
        guard let subMenuItems = action.subMenuItems, subMenuItems.count > 0 else {
            if action.handleBeforeDismiss {
                didSelectMenuAction?(action)
                action.handler?(action)
                dismiss(animated: true, completion: nil)
            } else {
                dismiss(animated: true) {
                    self.didSelectMenuAction?(action)
                    action.handler?(action)
                }
            }

            return
        }

        self.menuItems = subMenuItems
        self.reloadData(animated: true)
        self.updatePopoverContentSize(animated: true)
    }
    
    // MARK: - 显示菜单
    func show(from sourceView: UIView,
              sourceRect: CGRect? = nil,
              isCovered: Bool = true) {
        if menuItems.count == 0 {
            return
        }
        
        self.popoverShow(from: sourceView,
                         sourceRect: sourceRect,
                         isSourceViewCovered: isCovered,
                         preferredPosition: .bottomLeft,
                         permittedPositions: permittedPositions,
                         animated: true,
                         completion: nil)
    }
}
