//
//  WorkspacePluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation
import UIKit

class WorkspacePluginCell: UICollectionViewCell {
    
    /// 当前配置的组件
    private(set) var element: WSPluginElement?
    
    private(set) var provider: WSPluginProvider?
    
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
        self.setupContentSubviews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        /// 单元格样式会在 super 中被重置，这里重新应用组件外观
        updateAppearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        element = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupContentSubviews() {
        
    }
    
    // MARK: - 配置
    /// 通过组件配置单元格
    func configure(element: WSPluginElement, provider: WSPluginProvider) {
        self.element = element
        self.provider = provider
        updateAppearance()
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
