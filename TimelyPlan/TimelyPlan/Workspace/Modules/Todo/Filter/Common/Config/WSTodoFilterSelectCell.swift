//
//  WSTodoFilterSelectCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 分组

/// 待办过滤器选择列表的分组。
class WSTodoFilterGroup: NSObject, GroupRepresentable {
    
    /// 分组唯一标识
    let identifier: String
    
    /// 分组内过滤器
    var filters: [TodoFilter]?
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    // MARK: - GroupRepresentable
    var items: [ListDiffable]? {
        return filters
    }
    
    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? WSTodoFilterGroup else {
            return false
        }
        
        return identifier == other.identifier
    }
}

// MARK: - 列表单元格

/// 待办过滤器选择列表的单元格。左侧为颜色竖条，右侧为名称与对勾
class WSTodoFilterSelectCell: TPColorInfoTextValueTableCell {
    
    /// 颜色竖条尺寸及其与名称的间距。与待办首页过滤器保持一致
    private let colorBarSize = CGSize(width: 6.0, height: 16.0)
    private let colorBarMargins = UIEdgeInsets(left: 12.0, right: 12.0)
    
    /// 对勾图标
    private lazy var checkmarkView: UIImageView = {
        let view = UIImageView()
        view.image = resGetImage("checkmark_24")
        view.isHidden = true
        return view
    }()
    
    var filter: TodoFilter? {
        didSet {
            let colorConfig = TPColorAccessoryConfig()
            colorConfig.size = colorBarSize
            colorConfig.margins = colorBarMargins
            colorConfig.color = filter?.color ?? TodoFilter.defaultColor
            self.colorConfig = colorConfig
            
            self.infoView.title = filter?.name ?? resGetString("Untitled")
            setNeedsLayout()
        }
    }
    
    override func setupInfoView() {
        super.setupInfoView()
        
        /// 与待办清单选择一致：右侧展示对勾
        infoView.rightAccessoryView = checkmarkView
        infoView.rightAccessorySize = .mini
        infoView.rightAccessoryMargins = UIEdgeInsets(left: 10.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkmarkView.updateImage(withColor: tintColor)
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        checkmarkView.isHidden = !checked
    }
}
