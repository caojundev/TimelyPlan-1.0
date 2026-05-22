//
//  TPLevelMenuViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation
import UIKit

private struct TPLevelMenuListItem {
    
    /// 标题
    var title: String?
    
    /// 菜单条目
    var menuItems: [TPMenuItem]?
}

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
    private let minMenuContentHeight: CGFloat = 50.0
    private let maxMenuContentHeight: CGFloat = 520.0
    
    private let topbarHeight = 50.0
    private lazy var topbar: TPLevelMenuTopbar = {
        let topbar = TPLevelMenuTopbar()
        topbar.backgroundColor = themeBackgroundColor
        return topbar
    }()
    
    /// 列表视图
    private var listView = TPMenuListView()
    
    private var menuListItems: [TPLevelMenuListItem] = []
    
    init(menuItems: [TPMenuItem]) {
        let listItem = TPLevelMenuListItem(title: nil, menuItems: menuItems)
        self.menuListItems = [listItem]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(topbar)
        self.topbar.didClickBack = { [weak self] in
            self?.popMenu()
        }
        
        self.view.addSubview(listView)
        self.listView.didSelectMenuAction = { [weak self] action in
            self?.selectMenuAction(action)
        }
        
        self.reloadData(style: .none)
    }
    
    private var isTopbarHidden: Bool {
        if menuListItems.count <= 1 {
            return true
        }
        
        return false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutContent()
        updatePopoverContentSize()
    }
    
    private func layoutContent() {
        if isTopbarHidden {
            topbar.alpha = 0.0
            topbar.frame = CGRect(x: 0.0, y: -topbarHeight, width: view.bounds.width, height: topbarHeight)
            listView.frame = view.bounds
        } else {
            topbar.alpha = 1.0
            topbar.frame = CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: topbarHeight)
            listView.frame = CGRect(x: 0.0,
                                    y: topbarHeight,
                                    width: view.bounds.width,
                                    height: view.bounds.height - topbarHeight)
        }
    }

    override var themeBackgroundColor: UIColor? {
        return .secondarySystemGroupedBackground
    }
    
    override var popoverContentSize: CGSize {
        var contentSize = listView.contentSize
        contentSize.width = menuContentWidth
        let height = isTopbarHidden ? contentSize.height : contentSize.height + topbarHeight
        contentSize.height = clampedValue(height,
                                          minMenuContentHeight,
                                          maxMenuContentHeight)
        return contentSize
    }
    
    
    private func pushMenu(for action: TPMenuAction) {
        let menuListItem = TPLevelMenuListItem(title: action.title,
                                                menuItems: action.subMenuItems)
        menuListItems.append(menuListItem)
        reloadData(style: .rightToLeft)
        view.animateLayout(withDuration: 0.2)
        updatePopoverContentSize(animated: true)
    }
    
    private func popMenu() {
        guard menuListItems.count > 1 else {
            return
        }
        
        menuListItems.removeLast()
        reloadData(style: .leftToRight)
        view.animateLayout(withDuration: 0.2)
        updatePopoverContentSize(animated: true)
    }
    
    func reloadData(style: SlideStyle) {
        guard let listItem = menuListItems.last else {
            return
        }
        
        self.topbar.title = listItem.title
        self.listView.menuItems = listItem.menuItems
        if style != .none {
            listView.reloadData(animateStyle: style)
        } else {
            listView.reloadData()
        }
        
        view.setNeedsLayout()
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

        pushMenu(for: action)
    }

    // MARK: - 显示菜单
    func show(from sourceView: UIView,
              sourceRect: CGRect? = nil,
              isCovered: Bool = true) {
        guard menuListItems.count > 0 else {
            return
        }
        
        popoverShow(from: sourceView,
                     sourceRect: sourceRect,
                     isSourceViewCovered: isCovered,
                     preferredPosition: .bottomLeft,
                     permittedPositions: permittedPositions,
                     animated: true,
                     completion: nil)
    }
}


class TPLevelMenuTopbar: UIView {

    /// 点击返回
    var didClickBack: (() -> Void)?
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    // 标题标签
    private lazy var titleLabel: TPLabel = {
        let label = TPLabel()
        label.font = BOLD_SYSTEM_FONT
        label.textColor = resGetColor(.title)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    // 返回按钮
    private(set) lazy var backButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = .zero
        button.image = resGetImage("chevron_left_24")
        button.imageConfig.color = resGetColor(.title)
        button.addTarget(self,
                         action: #selector(clickBack(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        self.padding = UIEdgeInsets(horizontal: 16.0)
        addSubview(titleLabel)
        addSubview(backButton)
        addSeparator(position: .bottom)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = self.layoutFrame()
        backButton.size = .size(6)
        backButton.left = layoutFrame.minX
        backButton.centerY = layoutFrame.midY

        titleLabel.width = layoutFrame.width - 2 * backButton.width
        titleLabel.height = layoutFrame.height
        titleLabel.left = backButton.right
        titleLabel.top = layoutFrame.minY
    }
    
    // MARK: - Event Response
    @objc func clickBack(_ button: UIButton) {
        didClickBack?()
    }
}

