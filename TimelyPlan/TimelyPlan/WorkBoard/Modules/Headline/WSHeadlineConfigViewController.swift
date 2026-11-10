//
//  WSHeadlineConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation
import UIKit

// MARK: - 配置界面

/// 标题组件的配置界面，用于配置展示的标题与描述
class WSHeadlineConfigViewController: WSPluginConfigViewController {

    /// 当前配置
    private lazy var config: WSHeadlineConfiguration = {
        return configuration(as: WSHeadlineConfiguration.self) ?? WSHeadlineConfiguration()
    }()

    /// 标题与描述编辑界面
    private lazy var editingViewController: WSHeadlineEditingViewController = {
        let viewController = WSHeadlineEditingViewController(configuration: config)
        viewController.didChangeConfiguration = { [weak self] configuration in
            self?.config = configuration
            self?.updateConfiguration(configuration)
        }
        return viewController
    }()

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Headline")
        contentViewController = editingViewController
    }
}

// MARK: - 编辑界面

/// 标题与描述的编辑界面
class WSHeadlineEditingViewController: UIViewController, UITextFieldDelegate {

    /// 配置变化回调。编辑过程中实时回调，由配置界面在点击完成时统一保存
    var didChangeConfiguration: ((WSHeadlineConfiguration) -> Void)?

    /// 当前编辑的配置
    private var configuration: WSHeadlineConfiguration

    /// 布局尺寸
    private enum Metrics {

        /// 编辑区域与边缘的间距
        static let padding = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)

        /// 说明字号
        static let captionFont = UIFont.preferredFont(forTextStyle: .footnote)

        /// 输入框字号
        static let fieldFont = UIFont.preferredFont(forTextStyle: .body)

        /// 输入框高度
        static let fieldHeight: CGFloat = 44.0

        /// 输入框圆角
        static let fieldCornerRadius: CGFloat = 10.0

        /// 输入框内间距
        static let fieldContentInsets = UIEdgeInsets(horizontal: 12.0)

        /// 说明与输入框的间距
        static let captionFieldSpacing: CGFloat = 6.0

        /// 标题与描述之间的间距
        static let sectionSpacing: CGFloat = 20.0
    }

    /// 标题说明
    private let titleCaptionLabel = UILabel()

    /// 标题输入框
    private let titleTextField = TPTextField()

    /// 描述说明
    private let subtitleCaptionLabel = UILabel()

    /// 描述输入框
    private let subtitleTextField = TPTextField()

    init(configuration: WSHeadlineConfiguration) {
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

        setupCaptionLabel(titleCaptionLabel, text: resGetString("Title"))
        setupCaptionLabel(subtitleCaptionLabel, text: resGetString("Description"))
        setupTextField(titleTextField, text: configuration.title, placeholder: resGetString("Title"))
        setupTextField(subtitleTextField, text: configuration.subtitle, placeholder: resGetString("Description"))

        [titleCaptionLabel, titleTextField, subtitleCaptionLabel, subtitleTextField].forEach(view.addSubview)
    }

    // MARK: - 布局
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let contentFrame = view.layoutFrame()
        guard contentFrame.width > 0.0 else {
            return
        }

        let captionHeight = ceil(Metrics.captionFont.lineHeight)
        titleCaptionLabel.frame = CGRect(x: contentFrame.minX,
                                         y: contentFrame.minY,
                                         width: contentFrame.width,
                                         height: captionHeight)

        titleTextField.frame = CGRect(x: contentFrame.minX,
                                      y: titleCaptionLabel.bottom + Metrics.captionFieldSpacing,
                                      width: contentFrame.width,
                                      height: Metrics.fieldHeight)

        subtitleCaptionLabel.frame = CGRect(x: contentFrame.minX,
                                            y: titleTextField.bottom + Metrics.sectionSpacing,
                                            width: contentFrame.width,
                                            height: captionHeight)

        subtitleTextField.frame = CGRect(x: contentFrame.minX,
                                         y: subtitleCaptionLabel.bottom + Metrics.captionFieldSpacing,
                                         width: contentFrame.width,
                                         height: Metrics.fieldHeight)
    }

    // MARK: - 子视图
    private func setupCaptionLabel(_ label: UILabel, text: String) {
        label.text = text
        label.font = Metrics.captionFont
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
    }

    private func setupTextField(_ textField: TPTextField, text: String?, placeholder: String) {
        textField.text = text
        textField.placeholder = placeholder
        textField.font = Metrics.fieldFont
        textField.textColor = .label
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.layer.cornerRadius = Metrics.fieldCornerRadius
        textField.contentInsets = Metrics.fieldContentInsets
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = textField == titleTextField ? .next : .done
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }

    // MARK: - 编辑
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        configuration.title = titleTextField.text
        configuration.subtitle = subtitleTextField.text
        didChangeConfiguration?(configuration)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            subtitleTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return true
    }
}
