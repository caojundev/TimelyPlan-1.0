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
        static let padding = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)

        /// 说明字号
        static let captionFont = UIFont.preferredFont(forTextStyle: .footnote)

        /// 正文字号
        static let textFont = UIFont.preferredFont(forTextStyle: .body)

        /// 文本框高度
        static let textViewHeight: CGFloat = 120.0

        /// 文本框圆角
        static let textViewCornerRadius: CGFloat = 10.0

        /// 文本框内间距
        static let textViewContentInsets = UIEdgeInsets(top: 10.0, left: 8.0, bottom: 10.0, right: 8.0)

        /// 说明与文本框的间距
        static let captionTextSpacing: CGFloat = 6.0
    }

    /// 正文说明
    private let captionLabel = UILabel()

    /// 正文输入框
    private let textView = UITextView()

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

        captionLabel.text = resGetString("Body")
        captionLabel.font = Metrics.captionFont
        captionLabel.textColor = .secondaryLabel
        captionLabel.adjustsFontForContentSizeCategory = true

        textView.text = configuration.text
        textView.font = Metrics.textFont
        textView.textColor = .label
        textView.backgroundColor = .secondarySystemGroupedBackground
        textView.layer.cornerRadius = Metrics.textViewCornerRadius
        textView.textContainerInset = Metrics.textViewContentInsets
        textView.alwaysBounceVertical = true
        textView.delegate = self

        view.addSubview(captionLabel)
        view.addSubview(textView)
    }

    // MARK: - 布局
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let contentFrame = view.layoutFrame()
        guard contentFrame.width > 0.0 else {
            return
        }

        let captionHeight = ceil(Metrics.captionFont.lineHeight)
        captionLabel.frame = CGRect(x: contentFrame.minX,
                                    y: contentFrame.minY,
                                    width: contentFrame.width,
                                    height: captionHeight)

        let textTop = captionLabel.bottom + Metrics.captionTextSpacing
        textView.frame = CGRect(x: contentFrame.minX,
                                y: textTop,
                                width: contentFrame.width,
                                height: min(Metrics.textViewHeight, max(contentFrame.maxY - textTop, 0.0)))
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        configuration.text = textView.text
        didChangeConfiguration?(configuration)
    }
}
