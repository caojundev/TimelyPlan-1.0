//
//  WorkspacePluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation
import UIKit

/// 工作台组件单元格
class WorkspacePluginCell: UICollectionViewCell {
    
    /// 当前配置的组件
    private(set) var element: WSPluginElement?
    
    private(set) var provider: WSPluginProvider?
    
    /// 组件内容视图
    private(set) var pluginContentView: WorkspacePluginContentView!
    
    private(set) var interactor: WSPluginContentInteractor?
    
    // MARK: - 外观
    /// 组件背景色
    var pluginBackgroundColor: UIColor {
        return .secondarySystemGroupedBackground
    }
    
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
    func makePluginContentView() -> WorkspacePluginContentView! {
        return WorkspacePluginContentView()
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
    
    /// 应用组件外观：背景色、圆角
    private func updateAppearance() {
        let backColor = pluginBackgroundColor
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
        contentView.clipsToBounds = true
    }
}
