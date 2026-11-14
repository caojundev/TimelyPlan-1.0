//
//  WSActionItemEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/14.
//

import Foundation
import UIKit

// MARK: - 动作编辑

/// 单个动作的编辑界面。
///
/// 外壳与组件配置界面一致：左侧关闭、底部操作栏完成，内容由 `WSActionItemEditContentViewController` 提供。
class WSActionItemEditViewController: TPContainerViewController {

    /// 编辑完成回调
    var didEndEditing: ((WSActionItem) -> Void)?

    /// 删除动作回调，仅编辑模式有效
    var didDeleteAction: (() -> Void)?

    /// 编辑类型
    let editType: EditType

    /// 编辑内容
    private let editingViewController: WSActionItemEditContentViewController

    /// 传入 nil 表示新建动作
    init(actionItem: WSActionItem?) {
        self.editType = actionItem == nil ? .create : .modify

        let actionItem = actionItem ?? WSActionItem(colorHex: WSActionItem.defaultColor.hexString,
                                                    mode: .add,
                                                    addType: WSActionAddType.allCases.first)
        self.editingViewController = WSActionItemEditContentViewController(actionItem: actionItem)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = editType == .create ? resGetString("New Action") : resGetString("Edit Action")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.navigationItem.rightBarButtonItem = editType == .modify ? deleteBarButtonItem : nil
        preferredContentSize = AppLayout.Popover.extraLarge
        setupActionsBar(actions: [doneAction])
        contentViewController = editingViewController
    }

    /// 删除按钮，与列表左滑删除使用相同图标
    private lazy var deleteBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: resGetImage("trash_24"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(clickDelete))
        item.tintColor = .danger6
        return item
    }()

    @objc private func clickDelete() {
        TPImpactFeedback.impactWithMediumStyle()
        didDeleteAction?()
        dismiss(animated: true, completion: nil)
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    /// 内容区域避开底部操作栏
    override func contentViewFrame() -> CGRect {
        var frame = view.safeLayoutFrame()
        frame.size.height = max(frame.height - actionsBarHeight, 0.0)
        return frame
    }

    // MARK: - 完成
    override func clickDone() {
        didEndEditing?(editingViewController.actionItem)
        dismiss(animated: true, completion: nil)
    }
}
