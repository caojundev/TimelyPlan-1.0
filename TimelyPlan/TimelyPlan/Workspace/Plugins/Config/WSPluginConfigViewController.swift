//
//  WSPluginConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/19.
//

import Foundation
import UIKit

/// 组件配置视图控制器基类。
///
/// 每个组件可以有自己的配置界面：由 `WSPluginProvider.makeConfigViewController(plugin:)`
/// 返回具体的子类实例，返回 nil 表示该组件不支持配置。
///
/// 子类通过重写 `setupConfigSubviews()` 向 `contentView` 添加配置项，
/// 配置变化后调用 `updateConfigJSON(_:)`，由外部负责保存。
class WSPluginConfigViewController: TPViewController {
    
    /// 正在配置的组件
    let plugin: WSPlugin
    
    /// 配置 JSON 变化回调
    var didChangeConfigJSON: ((String?) -> Void)?
    
    /// 当前配置 JSON
    private(set) var configJSON: String?
    
    /// 配置项容器。子类将具体配置项添加到该视图
    let contentView = UIView()
    
    /// 系统关闭按钮
    private lazy var closeBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .close,
                               target: self,
                               action: #selector(didClickCancel))
    }()
    
    // MARK: - Initialization
    /// 统一的初始化入口，便于组件提供者创建配置界面
    init(plugin: WSPlugin) {
        self.plugin = plugin
        self.configJSON = plugin.configJSON
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = closeBarButtonItem
        preferredContentSize = AppLayout.Popover.extraLarge
        view.addSubview(contentView)
        setupConfigSubviews()
        setupActionsBar(actions: [doneAction])
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contentView.frame = view.safeLayoutFrame()
    }
    
    // MARK: - 子类重写
    /// 添加具体的配置项。子类重写该方法，将配置视图添加到 `contentView`
    func setupConfigSubviews() {
        
    }
    
    // MARK: - 配置
    /// 更新配置。发生变化时回调外部保存
    func updateConfigJSON(_ configJSON: String?) {
        guard self.configJSON != configJSON else {
            return
        }
        
        self.configJSON = configJSON
        didChangeConfigJSON?(configJSON)
    }
}
