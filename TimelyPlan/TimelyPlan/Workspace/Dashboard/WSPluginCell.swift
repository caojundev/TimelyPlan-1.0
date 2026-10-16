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
    private(set) var element: WSPluginElement?
    
    private(set) var provider: WSPluginProvider?
    
    /// 组件内容视图
    private(set) var pluginContentView: WSPluginContentView!
    
    private(set) var interactor: WSPluginContentInteractor?
    
    // MARK: - 外观
    /// 组件圆角半径
    var pluginCornerRadius: CGFloat {
        guard let size = element?.type.size else {
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
        updateAppearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetPluginContent()
        element = nil
        provider = nil
        interactor = nil
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
    func configure(element: WSPluginElement, provider: WSPluginProvider) {
        self.element = element
        self.provider = provider
        setupInteractor()
        interactor?.loadData()
        updateAppearance()
    }
    
    private func setupInteractor() {
        guard let element = element, let provider = provider else {
            return
        }
    
        interactor = provider.makeContentInteractor(element: element)
        interactor?.dataItemDidChange = { [weak self] dataItem in
            self?.pluginContentView?.update(with: dataItem)
        }
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
        guard isContextMenuEnabled, element != nil, !menuActionTypes.isEmpty else {
            return nil
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            return self?.makeContextMenu()
        }
    }
}
