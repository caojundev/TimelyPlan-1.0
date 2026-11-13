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
    
    /// 组件外观。由组件提供者决定，背景色为空时单元格透明
    private(set) var appearance: WSPluginAppearance = .default
    
    /// 组件内容视图
    private(set) var pluginContentView: WSPluginContentView!
    
    /// 当前内容视图对应的提供者类型。用于跨类型复用时判断是否需要替换内容视图
    private var contentProviderType: ObjectIdentifier?
    
    /// 数据加载期间的占位视图
    private(set) var placeholderView: UIView?
    
    /// 数据为空时展示的空白内容视图
    private(set) var emptyPlaceholderView: UIView?
    
    private(set) var interactor: WSPluginContentInteractor?
    
    /// 选中边框宽度
    private let selectionBorderWidth: CGFloat = 2.4
    
    /// 选中边框视图。编辑模式下选中插件时显示
    private lazy var selectionBorderView: UIView = {
        let view = UIView()
        view.layer.borderWidth = selectionBorderWidth
        view.isUserInteractionEnabled = false
        view.isHidden = true
        return view
    }()
    
    /// 是否被选中。由面板在编辑模式下维护，用于显示选中边框
    var isPluginSelected: Bool = false {
        didSet {
            selectionBorderView.isHidden = !isPluginSelected
            if isPluginSelected {
                bringSubviewToFront(selectionBorderView)
            }
        }
    }
    
    /// 是否处于编辑模式。编辑模式下内容视图不响应手势
    var isEditing: Bool = false {
        didSet {
            guard isEditing != oldValue else {
                return
            }
            
            updatePluginContentEnabled()
            emptyPlaceholderView?.isUserInteractionEnabled = !isEditing
        }
    }
    
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
        
        self.pluginContentView = WSPluginContentView()
        contentView.addSubview(pluginContentView)
        addSubview(selectionBorderView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pluginContentView.frame = contentView.bounds
        placeholderView?.frame = contentView.bounds
        emptyPlaceholderView?.frame = contentView.bounds
        selectionBorderView.frame = bounds
        updateAppearance()
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
        appearance = .default
        isPluginSelected = false
        isEditing = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 子类重写
    /// 重置插件内容
    func resetPluginContent() {

    }
    
    // MARK: - 内容视图
    /// 按提供者更新内容视图。同一类型复用时不重复创建，跨类型复用时替换。
    private func updatePluginContentViewIfNeeded(with provider: WSPluginProvider) {
        let providerType = ObjectIdentifier(type(of: provider))
        guard contentProviderType != providerType else {
            return
        }
        
        contentProviderType = providerType
        replacePluginContentView(with: provider.makeContentView())
    }
    
    /// 替换组件内容视图。内容视图置于最底层，占位视图始终覆盖在其上方
    private func replacePluginContentView(with contentView: WSPluginContentView) {
        pluginContentView?.removeFromSuperview()
        
        self.pluginContentView = contentView
        updatePluginContentEnabled()
        contentView.frame = self.contentView.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.insertSubview(contentView, at: 0)
        setNeedsLayout()
    }
    
    // MARK: - 配置
    /// 是否已经加载了相同内容的插件。内容未变化时无需重新配置
    func isLoaded(with plugin: WSPlugin) -> Bool {
        guard let currentPlugin = self.plugin else {
            return false
        }
        
        return currentPlugin.identifier == plugin.identifier
            && currentPlugin.type == plugin.type
            && currentPlugin.configJSON == plugin.configJSON
    }
    
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
        self.appearance = provider.appearance(for: plugin)
        
        /// 内容视图由提供者决定；先替换内容视图，再展示占位视图
        updatePluginContentViewIfNeeded(with: provider)
        showLoadingPlaceholderView()
        setupInteractor()
        interactor?.loadData()
        updateAppearance()
    }
    
    // MARK: - 主操作
    /// 执行组件的主操作。转发给内容交互器处理，单元格不关心具体业务。
    func performPrimaryAction() {
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
        
        interactor?.configActionHandler = isConfigurable ? { [weak self] in
            guard let self = self else { return }
            self.configActionHandler?(self)
        } : nil
        
        /// 交互器注入内容视图，内容内的点击、按钮等交互由内容视图直接调用
        pluginContentView?.interactor = interactor
    }
    
    // MARK: - 占位视图
    /// 创建加载占位视图。默认取 provider 提供的占位视图，未提供时使用默认加载占位视图。
    func makeLoadingPlaceholderView() -> UIView {
        return provider?.makeLoadingPlaceholderView() ?? WSPluginLoadingPlaceholderView()
    }
    
    /// 创建空白内容视图。
    ///
    /// 优先使用 provider 提供的自定义视图；未提供时使用默认空白内容视图，
    /// 并把 provider 的自定义配置项应用上去（未提供配置时使用默认配置）。
    func makeEmptyPlaceholderView() -> UIView {
        if let view = provider?.makeEmptyPlaceholderView() {
            return view
        }
        
        return WSPluginDefaultEmptyPlaceholderView(configuration: provider?.makeEmptyPlaceholderConfiguration())
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
            /// 与内容视图一致，空白视图也拿到交互器，内部的自定义操作直接交给它处理
            emptyView.interactor = interactor
            
            /// 支持配置的组件在空白态直接提供配置入口
            emptyView.configActionHandler = isConfigurable ? { [weak self] in
                guard let self = self else { return }
                self.configActionHandler?(self)
            } : nil
        }
        
        view.isUserInteractionEnabled = !isEditing
        emptyPlaceholderView = view
        contentView.addSubview(view)
        setNeedsLayout()
    }
    
    /// 移除空白内容视图
    func hideEmptyPlaceholderView() {
        emptyPlaceholderView?.removeFromSuperview()
        emptyPlaceholderView = nil
    }
    
    /// 应用组件外观：背景色与圆角
    private func updateAppearance() {
        let backColor = appearance.backgroundColor ?? .clear
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
        
        /// 选中效果跟随组件圆角与主题色
        selectionBorderView.layer.cornerRadius = cornerRadius
        selectionBorderView.layer.borderColor = UIColor.primary.cgColor
        selectionBorderView.backgroundColor = UIColor.primary.withAlphaComponent(0.1)
    }
    
    private func updatePluginContentEnabled() {
        pluginContentView.isUserInteractionEnabled = !isEditing && context != .gallery
    }
    
    // MARK: - 组件配置
    /// 组件是否支持配置
    var isConfigurable: Bool {
        return plugin?.isConfigurable ?? false
    }
    
    /// 点击配置入口回调
    var configActionHandler: ((WSPluginCell) -> Void)?
}
