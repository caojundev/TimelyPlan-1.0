//
//  WSBodyConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation
import UIKit

// MARK: - 配置界面

/// 正文组件的配置界面，用于配置展示的正文
class WSBodyConfigViewController: WSPluginConfigViewController {

    /// 当前配置
    private lazy var config: WSBodyConfiguration = {
        return configuration(as: WSBodyConfiguration.self) ?? WSBodyConfiguration()
    }()

    /// 正文编辑界面
    private lazy var editingViewController: WSBodyEditingViewController = {
        let viewController = WSBodyEditingViewController(configuration: config)
        viewController.didChangeConfiguration = { [weak self] configuration in
            self?.config = configuration
            self?.updateConfiguration(configuration)
        }
        return viewController
    }()

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Body")
        contentViewController = editingViewController
    }
}

// MARK: - 编辑界面

/// 正文的编辑界面
class WSBodyEditingViewController: UIViewController, UITextViewDelegate {

    /// 配置变化回调。编辑过程中实时回调，由配置界面在点击完成时统一保存
    var didChangeConfiguration: ((WSBodyConfiguration) -> Void)?

    /// 当前编辑的配置
    private var configuration: WSBodyConfiguration

    /// 布局尺寸
    private enum Metrics {

        /// 编辑区域与边缘的间距
        static let padding = UIEdgeInsets(value: 16.0)

        /// 文本框高度
        static let textViewHeight: CGFloat = 160.0

        /// 文本框圆角
        static let textViewCornerRadius: CGFloat = 10.0

        /// 文本框内间距
        static let textViewContentInsets = UIEdgeInsets(top: 10.0, left: 8.0, bottom: 10.0, right: 8.0)

        /// 文本框与文本样式选择视图的间距
        static let sectionSpacing: CGFloat = 12.0

        /// 对齐菜单按钮高度
        static let alignmentButtonHeight: CGFloat = 44.0

        /// 对齐菜单圆角
        static let alignmentCornerRadius: CGFloat = 10.0
    }

    /// 内容滚动视图
    private let contentView = UIScrollView()

    /// 正文输入框
    private let textView = UITextView()

    /// 文本样式选择视图
    private let styleSelectView = WSTextStyleSelectView()

    /// 文本对齐菜单
    private lazy var alignmentMenuView: TPSegmentedMenuView = {
        let view = TPSegmentedMenuView()
        view.normalBackgroundColor = .secondarySystemGroupedBackground
        view.cornerRadius = Metrics.alignmentCornerRadius
        view.preferredInnerRadius = 8.0
        view.padding = UIEdgeInsets(value: 8.0)
        view.buttonHeight = Metrics.alignmentButtonHeight
        view.didSelectMenuItem = { [weak self] menuItem in
            guard let self = self, let alignment = WSTextAlignment(rawValue: menuItem.tag) else {
                return
            }

            self.configuration.textAlignment = alignment
            self.textView.textAlignment = alignment.textAlignment
            self.didChangeConfiguration?(self.configuration)
        }

        view.menuItems = WSTextAlignment.segmentedMenuItems(style: .title)
        return view
    }()

    /// 当前选中的文本样式
    private var selectedTextStyle: WSTextStyle {
        return configuration.textStyle ?? .body
    }

    /// 当前选中的文本对齐方式
    private var selectedTextAlignment: WSTextAlignment {
        return configuration.textAlignment ?? .left
    }

    init(configuration: WSBodyConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.padding = Metrics.padding
        
        textView.text = configuration.text
        textView.font = selectedTextStyle.font
        textView.textAlignment = selectedTextAlignment.textAlignment
        textView.textColor = .label
        textView.backgroundColor = .secondarySystemGroupedBackground
        textView.layer.cornerRadius = Metrics.textViewCornerRadius
        textView.textContainerInset = Metrics.textViewContentInsets
        textView.alwaysBounceVertical = true
        textView.delegate = self
        
        styleSelectView.selectedTextStyle = selectedTextStyle
        styleSelectView.didSelectTextStyle = { [weak self] textStyle in
            guard let self = self else {
                return
            }

            self.configuration.textStyle = textStyle
            self.textView.font = textStyle.font
            self.didChangeConfiguration?(self.configuration)
        }

        alignmentMenuView.selectMenu(withTag: selectedTextAlignment.tag, animated: false)

        contentView.contentInsetAdjustmentBehavior = .never
        contentView.keyboardDismissMode = .interactive
        contentView.addSubview(textView)
        contentView.addSubview(styleSelectView)
        contentView.addSubview(alignmentMenuView)
        contentView.keyboardDismissMode = .onDrag
        view.addSubview(contentView)
    }

    // MARK: - 布局
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        contentView.frame = view.layoutFrame()

        let contentWidth = contentView.width
        guard contentWidth > 0.0 else {
            return
        }

        textView.frame = CGRect(x: 0.0,
                                y: 0.0,
                                width: contentWidth,
                                height: Metrics.textViewHeight)

        styleSelectView.frame = CGRect(x: 0.0,
                                       y: textView.bottom + Metrics.sectionSpacing,
                                       width: contentWidth,
                                       height: WSTextStyleSelectView.preferredHeight)

        alignmentMenuView.frame = CGRect(x: 0.0,
                                         y: styleSelectView.bottom + Metrics.sectionSpacing,
                                         width: contentWidth,
                                         height: alignmentMenuView.sizeThatFits(CGSize(width: contentWidth,
                                                                                     height: .greatestFiniteMagnitude)).height)

        contentView.contentSize = CGSize(width: contentWidth, height: alignmentMenuView.bottom)
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        configuration.text = textView.text
        didChangeConfiguration?(configuration)
    }
}
