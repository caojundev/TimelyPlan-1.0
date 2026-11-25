//
//  WSTodoTagSelectInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation
import UIKit

// MARK: - 已选标签信息

/// 已选标签信息视图。
///
/// 与待办的标签选择信息视图样式一致，区别在于标签按传入顺序展示，
/// 因此组件配置里保存的选择顺序可以直接体现在这里。
class WSTodoTagSelectInfoView: UIView {
    
    /// 已选标签，按组件内的展示顺序排列
    var tags: [TodoTag]? {
        didSet {
            updateSelectionCount()
            tagsLabel.update(with: tags?.attributedInfo())
        }
    }
    
    /// 最多可选择的标签数量
    var maximumSelectionCount: Int = 1 {
        didSet {
            updateSelectionCount()
        }
    }
    
    /// 标题高度
    private let descriptionHeight = 20.0

    /// 已选数量
    private let textLabel = TPLabel()
    
    /// 已选标签信息
    private let tagsLabel = TPLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        self.backgroundColor = .systemBackground
        self.clipsToBounds = true
        self.padding = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 4.0, right: 16.0)
        
        textLabel.textAlignment = .center
        textLabel.font = .systemFont(ofSize: 12.0, weight: .medium)
        textLabel.textColor = .secondaryLabel
        addSubview(textLabel)
        
        tagsLabel.textAlignment = .center
        tagsLabel.numberOfLines = 2
        tagsLabel.font = BOLD_SMALL_SYSTEM_FONT
        addSubview(tagsLabel)
        
        addSeparator(position: .top)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = self.layoutFrame()
        textLabel.width = layoutFrame.width
        textLabel.height = descriptionHeight
        textLabel.origin = layoutFrame.origin
        
        tagsLabel.width = layoutFrame.width
        tagsLabel.height = layoutFrame.height - descriptionHeight
        tagsLabel.left = layoutFrame.minX
        tagsLabel.top = textLabel.bottom
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var height = padding.verticalLength + descriptionHeight
        tagsLabel.width = size.width - padding.horizontalLength
        height += tagsLabel.sizeThatFits(size).height
        return CGSize(width: size.width, height: height)
    }
    
    // MARK: - 已选数量
    /// 更新已选数量与上限提示，与清单配置的底部提示保持一致
    private func updateSelectionCount() {
        let selectedCount = tags?.count ?? 0
        let countText = String(format: resGetString("%ld selected"), selectedCount)
        let maximumText = String(format: resGetString("Up to %ld"), maximumSelectionCount)
        textLabel.text = "\(countText) · \(maximumText)"
    }
}
