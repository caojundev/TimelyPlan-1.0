//
//  WSPluginEmptyPlaceholderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/19.
//

import Foundation
import UIKit

// MARK: - 空白内容配置

/// 工作台组件默认空白内容视图的配置。
///
/// 涵盖图标、描述与「配置插件」按钮的样式，字段均有默认值且与设计一致，按需覆盖即可。
struct WSPluginEmptyPlaceholderConfiguration {
    
    // MARK: 图标
    /// 图标（系统符号名称）
    var iconName: String = "info.circle"
    
    /// 图标尺寸
    var iconSize: CGSize = CGSize(width: 32.0, height: 32.0)
    
    /// 图标颜色
    var iconColor: UIColor = .tertiaryLabel
    
    // MARK: 描述
    /// 描述文字
    var title: String = resGetString("No Content")
    
    /// 描述文字字体
    var titleFont: UIFont = .systemFont(ofSize: 14.0)
    
    /// 描述文字颜色
    var titleColor: UIColor = .secondaryLabel
    
    // MARK: 配置按钮
    /// 按钮标题
    var buttonTitle: String = resGetString("Configure Plugin")
    
    /// 按钮标题字体
    var buttonTitleFont: UIFont = .systemFont(ofSize: 14.0, weight: .medium)
    
    /// 按钮标题颜色
    var buttonTitleColor: UIColor = .primary
    
    /// 按钮按下时的标题颜色
    var buttonHighlightedTitleColor: UIColor = .primary
    
    /// 按钮选中时的标题颜色
    var buttonSelectedTitleColor: UIColor = .primary
    
    /// 按钮常规背景色
    var buttonBackgroundColor: UIColor = .primary.withAlphaComponent(0.1)
    
    /// 按钮按下 / 选中时的背景色
    var buttonSelectedBackgroundColor: UIColor = .primary.withAlphaComponent(0.16)
    
    /// 按钮高度
    var buttonHeight: CGFloat = 44.0
    
    /// 按钮圆角
    var buttonCornerRadius: CGFloat = .greatestFiniteMagnitude
}

// MARK: - 空白内容视图基类

/// 工作台组件空白内容视图基类。
///
/// 与 `WSPluginContentView` 相对应：内容视图负责渲染数据，空白视图负责展示「暂无内容」并提供操作入口。
/// 基类统一持有交互器、配置回调与内容边距，子类只负责搭建和布局自己的内容。
class WSPluginEmptyPlaceholderView: UIView {
    
    /// 内容交互器。由单元格注入，空白视图内的操作可直接交给它处理
    weak var interactor: WSPluginContentInteractor?
    
    /// 点击「配置插件」回调
    var configActionHandler: (() -> Void)? {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 内容与视图边缘的内边距
    var contentInsets: UIEdgeInsets = UIEdgeInsets(value: 12.0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 子类实现
    /// 布局子视图
    /// - Parameter layoutFrame: 已去掉 `contentInsets` 的可用区域
    func layoutContent(in layoutFrame: CGRect) {
        
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutContent(in: bounds.inset(by: contentInsets))
    }
}

// MARK: - 默认空白内容视图

/// 工作台组件默认空白内容视图。
///
/// 顶部图标、中间描述、底部「配置插件」按钮；组件不支持配置（未提供 `configActionHandler`）时
/// 只展示图标与描述。图标、文案与按钮样式由初始化时传入的配置决定。
class WSPluginDefaultEmptyPlaceholderView: WSPluginEmptyPlaceholderView {
    
    /// 布局参数
    private enum Metrics {
        
        /// 图标与描述的间距
        static let iconTitleSpacing: CGFloat = 12.0
        
        /// 描述与按钮的间距
        static let titleButtonSpacing: CGFloat = 12.0
    }
    
    /// 配置项
    private let configuration: WSPluginEmptyPlaceholderConfiguration
    
    /// 图标
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// 描述文字
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    /// 配置插件按钮
    private lazy var configButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.didClickHandler = { [weak self] in
            self?.configActionHandler?()
        }
        return button
    }()
    
    /// 初始化空白内容视图
    /// - Parameter configuration: 配置项。传 nil 时使用默认配置
    init(configuration: WSPluginEmptyPlaceholderConfiguration? = nil) {
        self.configuration = configuration ?? WSPluginEmptyPlaceholderConfiguration()
        super.init(frame: .zero)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 配置
    /// 把配置项应用到子视图
    private func setupSubviews() {
        iconView.image = UIImage(systemName: configuration.iconName)
        iconView.tintColor = configuration.iconColor
        
        titleLabel.text = configuration.title
        titleLabel.font = configuration.titleFont
        titleLabel.textColor = configuration.titleColor
        
        configButton.title = configuration.buttonTitle
        configButton.titleConfig.font = configuration.buttonTitleFont
        configButton.titleConfig.textColor = configuration.buttonTitleColor
        configButton.titleConfig.highlightedTextColor = configuration.buttonHighlightedTitleColor
        configButton.titleConfig.selectedTextColor = configuration.buttonSelectedTitleColor
        configButton.normalBackgroundColor = configuration.buttonBackgroundColor
        configButton.selectedBackgroundColor = configuration.buttonSelectedBackgroundColor
        
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(configButton)
    }
    
    // MARK: - 布局
    override func layoutContent(in layoutFrame: CGRect) {
        guard layoutFrame.height > 0.0 else {
            return
        }
        
        /// 未提供配置回调时不展示按钮
        let showsButton = configActionHandler != nil
        configButton.isHidden = !showsButton
        
        /// 图标尺寸不超过可用空间
        let iconWidth = min(configuration.iconSize.width, layoutFrame.width)
        let iconHeight = min(configuration.iconSize.height, layoutFrame.height)
        
        let titleSize = titleLabel.sizeThatFits(CGSize(width: layoutFrame.width,
                                                       height: .greatestFiniteMagnitude))
        let buttonHeight = min(configuration.buttonHeight, layoutFrame.height * 0.3)
        
        /// 图标、描述、按钮整体垂直居中
        var contentHeight = iconHeight + Metrics.iconTitleSpacing + titleSize.height
        if showsButton {
            contentHeight += Metrics.titleButtonSpacing + buttonHeight
        }
        let originY = layoutFrame.minY + max((layoutFrame.height - contentHeight) / 2.0, 0.0)
        
        iconView.frame = CGRect(x: layoutFrame.midX - iconWidth / 2.0,
                                y: originY,
                                width: iconWidth,
                                height: iconHeight)
        
        titleLabel.frame = CGRect(x: layoutFrame.minX,
                                  y: iconView.frame.maxY + Metrics.iconTitleSpacing,
                                  width: layoutFrame.width,
                                  height: titleSize.height)
        
        guard showsButton else {
            return
        }
        
        configButton.frame = CGRect(x: layoutFrame.minX,
                                    y: titleLabel.frame.maxY + Metrics.titleButtonSpacing,
                                    width: layoutFrame.width,
                                    height: buttonHeight)
        configButton.cornerRadius = configuration.buttonCornerRadius
    }
}
