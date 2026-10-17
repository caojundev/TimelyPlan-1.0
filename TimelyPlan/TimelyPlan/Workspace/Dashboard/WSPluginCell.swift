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
    
    /// 组件内容视图
    private(set) var pluginContentView: WSPluginContentView!
    
    /// 数据加载期间的占位视图
    private(set) var placeholderView: UIView?
    
    private(set) var interactor: WSPluginContentInteractor?
    
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
        contentView.addInteraction(contextMenuInteraction)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pluginContentView.frame = contentView.bounds
        placeholderView?.frame = contentView.bounds
        updateAppearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetPluginContent()
        /// 复用前先回到占位态，等待重新加载数据
        showPlaceholderView()
        plugin = nil
        provider = nil
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
    func configure(plugin: WSPlugin, provider: WSPluginProvider) {
        self.plugin = plugin
        self.provider = provider
        /// 先展示占位视图，数据加载完成后再展示内容视图
        showPlaceholderView()
        setupInteractor()
        interactor?.loadData()
        updateAppearance()
    }
    
    private func setupInteractor() {
        guard let plugin = plugin, let provider = provider else {
            return
        }
    
        interactor = provider.makeContentInteractor(plugin: plugin)
        interactor?.dataItemDidChange = { [weak self] dataItem in
            guard let self = self else {
                return
            }
            
            /// 数据加载完成，隐藏占位视图并展示内容
            self.hidePlaceholderView()
            self.pluginContentView?.update(with: dataItem)
        }
    }
    
    // MARK: - 占位视图
    /// 创建占位视图。默认取 provider 提供的占位视图，未提供时使用默认占位视图。
    func makePlaceholderView() -> UIView {
        return provider?.makePlaceholderView() ?? WSPluginDefaultPlaceholderView()
    }
    
    /// 展示占位视图并隐藏内容视图
    func showPlaceholderView() {
        pluginContentView?.isHidden = true
        
        let view = makePlaceholderView()
        placeholderView?.removeFromSuperview()
        placeholderView = view
        contentView.addSubview(view)
        setNeedsLayout()
    }
    
    /// 移除占位视图并展示内容视图
    func hidePlaceholderView() {
        placeholderView?.removeFromSuperview()
        placeholderView = nil
        pluginContentView?.isHidden = false
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
        if isJiggling {
            startJiggling()
        } else {
            stopJiggling()
        }
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
    
    /// 长按菜单显示的动作。默认全部显示，子类可重写裁剪
    var menuActionTypes: [MenuActionType] {
        return MenuActionType.allCases
    }
    
    /// 长按菜单动作回调
    var menuActionHandler: ((WSPluginCell, MenuActionType) -> Void)?
    
    /// 菜单动作类型
    enum MenuActionType: Int, CaseIterable {
        case addPlugin /// 添加插件
        case edit      /// 编辑
        case remove    /// 移除
        
        /// 菜单标题
        var title: String {
            switch self {
            case .addPlugin:
                return resGetString("Add Plugin")
            case .edit:
                return resGetString("Edit Plugin")
            case .remove:
                return resGetString("Remove Plugin")
            }
        }
        
        /// 菜单图标
        var image: UIImage? {
            switch self {
            case .addPlugin:
                return UIImage(systemName: "plus.square.on.square")
            case .edit:
                return UIImage(systemName: "square.and.pencil")
            case .remove:
                return UIImage(systemName: "trash")
            }
        }
        
        /// 菜单属性
        var attributes: UIMenuElement.Attributes {
            switch self {
            case .remove:
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
        let actions = menuActionTypes.map { actionType in
            return UIAction(title: actionType.title,
                            image: actionType.image,
                            attributes: actionType.attributes) { [weak self] _ in
                guard let self = self else {
                    return
                }
                
                self.menuActionHandler?(self, actionType)
            }
        }
        
        return UIMenu(title: "", children: actions)
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

// MARK: - 默认占位视图

/// 工作台组件默认占位视图。
///
/// 三行宽度不等、带圆角的灰色横条，整体靠左上角对齐，用于数据加载完成前的占位展示。
class WSPluginDefaultPlaceholderView: UIView {
    
    /// 横条高度
    private let barHeight: CGFloat = 12.0
    
    /// 横条间距
    private let barSpacing: CGFloat = 8.0
    
    /// 横条圆角半径
    private let barCornerRadius: CGFloat = 6.0
    
    /// 横条距视图边缘的内边距
    private let contentInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
    
    /// 三行横条的宽度占比（占可用宽度）
    private let barWidthRatios: [CGFloat] = [0.6, 0.9, 0.4]
    
    /// 横条
    private lazy var barViews: [UIView] = {
        return barWidthRatios.map { _ in
            let barView = UIView()
            barView.backgroundColor = .systemGray5
            barView.layer.masksToBounds = true
            return barView
        }
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
        barViews.forEach { addSubview($0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /// 可用宽度
        let availableWidth = max(bounds.width - contentInsets.left - contentInsets.right, 0.0)
        
        /// 横条高度，受可用高度限制，避免小尺寸组件中横条溢出
        let availableHeight = bounds.height - contentInsets.top - contentInsets.bottom
        let spacingHeight = barSpacing * CGFloat(max(barViews.count - 1, 0))
        let barHeight = min(self.barHeight,
                            max((availableHeight - spacingHeight) / CGFloat(max(barViews.count, 1)), 0.0))
        
        /// 圆角半径不超过横条高度的一半
        let cornerRadius = min(barCornerRadius, barHeight / 2.0)
        
        var originY = contentInsets.top
        for (index, barView) in barViews.enumerated() {
            let width = availableWidth * barWidthRatios[index]
            barView.frame = CGRect(x: contentInsets.left, y: originY, width: width, height: barHeight)
            barView.layer.cornerRadius = cornerRadius
            originY = barView.frame.maxY + barSpacing
        }
    }
}
