//
//  WSPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation
import UIKit

/// 工作台组件单元格
class WSPluginCell: UICollectionViewCell {
    
    /// 当前配置的组件
    private(set) var plugin: WSPlugin?
    
    private(set) var provider: WSPluginProvider?
    
    /// 展示上下文。决定交互器读取真实数据还是画廊预览数据
    private var context: WSPluginContext = .dashboard
    
    /// 组件内容视图
    private(set) var pluginContentView: WSPluginContentView!
    
    /// 数据加载期间的占位视图
    private(set) var placeholderView: UIView?
    
    /// 数据为空时展示的空白内容视图
    private(set) var emptyPlaceholderView: UIView?
    
    private(set) var interactor: WSPluginContentInteractor?
    
    /// 点击删除按钮回调。仅在编辑模式下显示删除按钮
    var deleteActionHandler: ((WSPluginCell) -> Void)?
    
    /// 删除按钮尺寸
    private let deleteButtonSize = CGSize(width: 24.0, height: 24.0)
    
    /// 删除按钮与右上角的间距
    private let deleteButtonMargin: CGFloat = 6.0
    
    /// 编辑模式下的删除按钮
    private lazy var deleteButton: TPImageButton = {
        let button = TPImageButton()
        button.normalImage = resGetImage("xmark_circle_fill_24")
        button.normalImageColor = .danger6
        button.imageSize = deleteButtonSize
        button.padding = .zero
        button.hitTestEdgeInsets = UIEdgeInsets(value: -deleteButtonMargin)
        button.isHidden = true
        button.addTarget(self, action: #selector(clickDelete(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - 外观
    /// 组件圆角半径
    var pluginCornerRadius: CGFloat {
        guard let size = plugin?.type.size else {
            return 16.0
        }
        
        return size == .large ? 22.0 : 16.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.backgroundView = UIView()
        self.backgroundView?.clipsToBounds = true
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.clipsToBounds = true
        
        self.pluginContentView = makePluginContentView()
        contentView.addSubview(pluginContentView)
        addSubview(deleteButton)
        contentView.addInteraction(contextMenuInteraction)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pluginContentView.frame = contentView.bounds
        placeholderView?.frame = contentView.bounds
        emptyPlaceholderView?.frame = contentView.bounds
        layoutDeleteButton()
        updateAppearance()
    }
    
    /// 布局右上角的删除按钮
    private func layoutDeleteButton() {
        deleteButton.size = deleteButtonSize
        deleteButton.right = contentView.width - deleteButtonMargin
        deleteButton.top = deleteButtonMargin
        
        if !deleteButton.isHidden {
            bringSubviewToFront(deleteButton)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetPluginContent()
        hideEmptyPlaceholderView()
        /// 复用前先回到占位态，等待重新加载数据
        showLoadingPlaceholderView()
        plugin = nil
        provider = nil
        context = .dashboard
        interactor = nil
        setJiggling(false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 子类重写
    func makePluginContentView() -> WSPluginContentView! {
        return WSPluginContentView()
    }
    
    /// 重置插件内容
    func resetPluginContent() {

    }
    
    // MARK: - 配置
    /// 通过组件配置单元格
    ///
    /// - Parameter context: 展示上下文。仪表盘传 `.dashboard` 读取真实数据，
    ///   画廊传 `.gallery` 展示固定预览数据。
    func configure(plugin: WSPlugin,
                   provider: WSPluginProvider,
                   context: WSPluginContext = .dashboard) {
        self.plugin = plugin
        self.provider = provider
        self.context = context
        /// 先展示占位视图，数据加载完成后再展示内容视图
        showLoadingPlaceholderView()
        setupInteractor()
        interactor?.loadData()
        updateAppearance()
    }
    
    // MARK: - 主操作
    /// 执行组件的主操作。转发给内容交互器处理，单元格不关心具体业务。
    func performPrimaryAction() {
        guard !isJiggling else {
            return
        }
        
        interactor?.performPrimaryAction()
    }
    
    private func setupInteractor() {
        guard let plugin = plugin, let provider = provider else {
            return
        }
    
        interactor = provider.makeContentInteractor(plugin: plugin, context: context)
        interactor?.dataItemDidChange = { [weak self] dataItem in
            guard let self = self else {
                return
            }
            
            /// 数据加载完成，隐藏加载占位视图
            self.hideLoadingPlaceholderView()
            
            /// 有数据时渲染内容，没有数据时展示空白内容视图
            self.pluginContentView?.update(with: dataItem)
            if dataItem == nil {
                self.showEmptyPlaceholderView()
            } else {
                self.hideEmptyPlaceholderView()
            }
        }
    }
    
    // MARK: - 占位视图
    /// 创建加载占位视图。默认取 provider 提供的占位视图，未提供时使用默认加载占位视图。
    func makeLoadingPlaceholderView() -> UIView {
        return provider?.makeLoadingPlaceholderView() ?? WSPluginLoadingPlaceholderView()
    }
    
    /// 创建空白内容视图。默认取 provider 提供的视图，未提供时使用默认空白内容视图。
    func makeEmptyPlaceholderView() -> UIView {
        return provider?.makeEmptyPlaceholderView() ?? WSPluginEmptyPlaceholderView()
    }
    
    /// 展示加载占位视图并隐藏内容视图
    func showLoadingPlaceholderView() {
        hideEmptyPlaceholderView()
        pluginContentView?.isHidden = true
        
        let view = makeLoadingPlaceholderView()
        placeholderView?.removeFromSuperview()
        placeholderView = view
        contentView.addSubview(view)
        setNeedsLayout()
    }
    
    /// 移除加载占位视图并展示内容视图
    func hideLoadingPlaceholderView() {
        placeholderView?.removeFromSuperview()
        placeholderView = nil
        pluginContentView?.isHidden = false
    }
    
    /// 展示空白内容视图并隐藏内容视图
    func showEmptyPlaceholderView() {
        pluginContentView?.isHidden = true
        
        guard emptyPlaceholderView == nil else {
            return
        }
        
        let view = makeEmptyPlaceholderView()
        if let emptyView = view as? WSPluginEmptyPlaceholderView {
            /// 支持配置的组件在空白态直接提供配置入口，与长按菜单的「配置」项一致
            emptyView.configActionHandler = isConfigurable ? { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.menuActionHandler?(self, .configPlugin)
            } : nil
        }
        view.isUserInteractionEnabled = !isJiggling
        emptyPlaceholderView = view
        contentView.addSubview(view)
        setNeedsLayout()
    }
    
    /// 移除空白内容视图
    func hideEmptyPlaceholderView() {
        emptyPlaceholderView?.removeFromSuperview()
        emptyPlaceholderView = nil
    }
    
    /// 应用组件外观：圆角
    private func updateAppearance() {
        let backColor: UIColor = .secondarySystemGroupedBackground
        backgroundView?.backgroundColor = backColor
        selectedBackgroundView?.backgroundColor = backColor
        
        /// 更新圆角半径
        var cornerRadius = pluginCornerRadius
        cornerRadius = min(cornerRadius, contentView.size.shortSideLength / 2.0)
        backgroundView?.layer.cornerRadius = cornerRadius
        selectedBackgroundView?.layer.cornerRadius = cornerRadius
        backgroundView?.layer.zPosition = -1
        selectedBackgroundView?.layer.zPosition = -1
        contentView.layer.cornerRadius = cornerRadius
        contentView.backgroundColor = backColor
        contentView.clipsToBounds = true
    }
    
    // MARK: - 排序抖动
    /// 抖动动画的标识
    private static let jiggleAnimationKey = "jiggle"
    
    /// 是否处于抖动状态
    private(set) var isJiggling: Bool = false
    
    /// 设置抖动状态。排序模式下开启，用于提示组件可拖动排序。
    func setJiggling(_ isJiggling: Bool) {
        guard self.isJiggling != isJiggling else {
            return
        }
        
        self.isJiggling = isJiggling
        /// 删除按钮仅在编辑（抖动）模式下显示
        deleteButton.isHidden = !isJiggling
        pluginContentView.isUserInteractionEnabled = !isJiggling
        emptyPlaceholderView?.isUserInteractionEnabled = !isJiggling
        if isJiggling {
            bringSubviewToFront(deleteButton)
            startJiggling()
        } else {
            stopJiggling()
        }
    }
    
    /// 点击删除按钮
    @objc private func clickDelete(_ sender: TPImageButton) {
        deleteActionHandler?(self)
    }
    
    /// 开始抖动
    private func startJiggling() {
        guard layer.animation(forKey: Self.jiggleAnimationKey) == nil else {
            return
        }
        
        /// 左右各轻微旋转，形成与系统小组件一致的抖动效果
        let angle = CGFloat.pi / 180.0
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        animation.values = [-angle, angle, -angle]
        animation.keyTimes = [0.0, 0.5, 1.0]
        animation.duration = 0.3
        animation.repeatCount = .greatestFiniteMagnitude
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(animation, forKey: Self.jiggleAnimationKey)
    }
    
    /// 结束抖动
    private func stopJiggling() {
        layer.removeAnimation(forKey: Self.jiggleAnimationKey)
    }
    
    // MARK: - 长按菜单
    /// 是否支持长按弹出菜单
    var isContextMenuEnabled: Bool = true
    
    /// 长按菜单动作分组
    var menuActionTypeGroups: [[MenuActionType]] {
        var groups: [[MenuActionType]] = [[.editDashboard],
                                          [.addPreviousPlugin, .addNextPlugin]]
        
        /// 组件不支持配置时，插件操作分组中不显示配置项
        if isConfigurable {
            groups.append([.configPlugin, .removePlugin])
        } else {
            groups.append([.removePlugin])
        }
        
        return groups
    }
    
    /// 组件是否支持配置。由组件提供者决定
    var isConfigurable: Bool {
        guard let plugin = plugin, let provider = provider else {
            return false
        }
        
        return provider.makeConfigViewController(plugin: plugin) != nil
    }
    
    /// 长按菜单显示的动作。默认全部分组内的动作，子类可重写裁剪
    var menuActionTypes: [MenuActionType] {
        return menuActionTypeGroups.flatMap { $0 }
    }
    
    /// 长按菜单动作回调
    var menuActionHandler: ((WSPluginCell, MenuActionType) -> Void)?
    
    /// 菜单动作类型
    enum MenuActionType: Int, CaseIterable {
        case editDashboard     /// 编辑面板
        case addPreviousPlugin /// 添加上一个插件
        case addNextPlugin     /// 添加下一个插件
        case configPlugin      /// 配置插件
        case removePlugin      /// 移除插件
        
        /// 菜单标题
        var title: String {
            switch self {
            case .addPreviousPlugin:
                return resGetString("Add Previous Plugin")
            case .addNextPlugin:
                return resGetString("Add Next Plugin")
            case .editDashboard:
                return resGetString("Edit Dashboard")
            case .configPlugin:
                return resGetString("Config Plugin")
            case .removePlugin:
                return resGetString("Remove Plugin")
            }
        }
        
        /// 菜单图标
        var image: UIImage? {
            switch self {
            case .addPreviousPlugin:
                return UIImage(systemName: "arrow.up.square")
            case .addNextPlugin:
                return UIImage(systemName: "arrow.down.square")
            case .editDashboard:
                return UIImage(systemName: "square.and.pencil")
            case .configPlugin:
                return UIImage(systemName: "slider.horizontal.3")
            case .removePlugin:
                return UIImage(systemName: "trash")
            }
        }
        
        /// 菜单属性
        var attributes: UIMenuElement.Attributes {
            switch self {
            case .removePlugin:
                return .destructive
            default:
                return []
            }
        }
    }
    
    /// 长按手势交互
    private lazy var contextMenuInteraction: UIContextMenuInteraction = {
        return UIContextMenuInteraction(delegate: self)
    }()
    
    /// 构建长按菜单
    private func makeContextMenu() -> UIMenu {
        /// 每个分组使用内联子菜单，分组之间由系统绘制分割线
        let groups = menuActionTypeGroups.compactMap { actionTypes -> UIMenu? in
            let actions = actionTypes.map { actionType in
                return UIAction(title: actionType.title,
                                image: actionType.image,
                                attributes: actionType.attributes) { [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    
                    self.menuActionHandler?(self, actionType)
                }
            }
            
            guard actions.count > 0 else {
                return nil
            }
            
            return UIMenu(title: "", options: .displayInline, children: actions)
        }
        
        return UIMenu(title: "", children: groups)
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension WSPluginCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        /// 未开启长按菜单、未配置组件或无可用动作时不响应长按
        guard isContextMenuEnabled, plugin != nil, !menuActionTypes.isEmpty else {
            return nil
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            return self?.makeContextMenu()
        }
    }
}
