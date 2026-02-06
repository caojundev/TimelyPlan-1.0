//
//  TPBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/4.
//

import Foundation
import UIKit

class TPBarButtonItem: NSObject {
    
    lazy var identifier: String = {
        return UUID().uuidString
    }()
    
    enum Style {
        case normal  /// 正常
        case flexibleSpace /// 空白
    }
    
    /// 样式
    var style: Style = .normal
    
    /// 标题
    var title: String?
    
    /// 图标
    var image: UIImage?
    
    /// 颜色
    var color: UIColor? = resGetColor(.title)
    
    /// 自定义视图
    var customView: UIView?
    
    /// 是否可用
    @objc dynamic var isEnabled: Bool = true
    
    /// 动作回调
    var handler: ((TPBarButtonItem) -> Void)?
    
    static var flexibleSpaceButtonItem: TPBarButtonItem {
        let item = TPBarButtonItem()
        item.style = .flexibleSpace
        return item
    }
    
    convenience init(title: String?, handler: ((TPBarButtonItem) -> Void)?) {
        self.init()
        self.title = title
        self.handler = handler
    }
    
    convenience init(image: UIImage?, color: UIColor? = nil, handler: ((TPBarButtonItem) -> Void)?) {
        self.init()
        self.image = image
        self.color = color ?? resGetColor(.title)
        self.handler = handler
    }
    
    convenience init(customView: UIView, handler: ((TPBarButtonItem) -> Void)?) {
        self.init()
        self.customView = customView
        self.handler = handler
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TPBarButtonItem else { return false }
        if self === other { return true }
        return identifier == other.identifier
    }
    
}
