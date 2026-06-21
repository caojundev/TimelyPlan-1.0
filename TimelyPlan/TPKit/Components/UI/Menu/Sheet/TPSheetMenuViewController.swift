//
//  TPSheetMenuViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/4.
//

import Foundation
import UIKit

class TPSheetMenuViewController: TPTableViewController,
                                 TPTableViewAdapterDataSource,
                                 TPTableViewAdapterDelegate {
    /// 元素间距
    var titleMargins = UIEdgeInsets(top: 20.0, bottom: 10.0)
    
    /// 头高度
    let sectionHeaderHeight = 10.0
    
    /// 行高度
    let rowHeight = 60.0
    
    /// 选中菜单动作回调
    var didSelectMenuAction: ((TPMenuAction) -> Void)?
    
    private(set) var menuItems: [TPMenuItem]
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingMiddle
        label.numberOfLines = 2
        label.textColor = resGetColor(.title)
        return label
    }()
    
    override var title: String? {
        didSet {
            self.titleLabel.text = title
            self.view.setNeedsLayout()
        }
    }
    
    convenience init(title: String?, menuItems: [TPMenuItem]) {
        self.init(menuItems: menuItems)
        self.title = title
    }
    
    init(menuItems: [TPMenuItem]) {
        self.menuItems = menuItems
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(titleLabel)
        self.setupActionsBar(actions: [doneAction])
        self.adapter.dataSource = self
        self.adapter.delegate = self
        self.adapter.reloadData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let layoutFrame = view.layoutFrame()
        let titleSize = titleLabel.sizeThatFits(layoutFrame.size)
        self.titleLabel.size = titleSize
        self.titleLabel.top = titleMargins.top
        self.titleLabel.centerX = layoutFrame.midX
        self.updatePopoverContentSize()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func tableViewFrame() -> CGRect {
        let layoutFrame = view.layoutFrame()
        var y = layoutFrame.minY + titleMargins.verticalLength
        y += titleLabel.sizeThatFits(layoutFrame.size).height
        let h = layoutFrame.height - y - actionsBarHeight
        return CGRect(x: layoutFrame.minX, y: y, width: layoutFrame.width, height: h)
    }

    override var popoverContentSize: CGSize {
        let tableViewFrame = tableViewFrame()
        var contentHeight = tableViewFrame.minY
        contentHeight += wrapperView.contentSize.height + actionsBarHeight
        return CGSize(width: AppLayout.Popover.preferredContentWidth, height: contentHeight)
    }

    override func clickDone() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - dataSource
    func sectionObjects(for adapter: TPTableViewAdapter) -> [ListDiffable]? {
        return menuItems
    }
    
    func adapter(_ adapter: TPTableViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        let menuItem = sectionObject as! TPMenuItem
        return menuItem.actions
    }
    
    // MARK: - Delegate
    func adapter(_ adapter: TPTableViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return TPSheetMenuTableCell.self
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didDequeCell cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! TPSheetMenuTableCell
        cell.menuAction = adapter.item(at: indexPath) as? TPMenuAction
    }
    
    func adapter(_ adapter: TPTableViewAdapter, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }

    func adapter(_ adapter: TPTableViewAdapter, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }

    func adapter(_ adapter: TPTableViewAdapter, didSelectRowAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        let action = adapter.item(at: indexPath) as! TPMenuAction
        if action.handleBeforeDismiss {
            action.handler?(action)
            self.didSelectMenuAction?(action)
            self.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true) {
                self.didSelectMenuAction?(action)
                action.handler?(action)
            }
        }
    }

    func adapter(_ adapter: TPTableViewAdapter, styleForRowAt indexPath: IndexPath) -> TPTableCellStyle? {
        let menuAction = adapter.item(at: indexPath) as! TPMenuAction
        return cellStyle(for: menuAction)
    }
    
    // MARK: - Style
    private func cellStyle(for menuAction: TPMenuAction) -> TPTableCellStyle {
        let style = TPTableCellStyle()
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .secondarySystemFill
        return style
    }
}
