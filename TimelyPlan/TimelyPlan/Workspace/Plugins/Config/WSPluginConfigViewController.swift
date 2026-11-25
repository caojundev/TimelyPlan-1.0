//
//  WSPluginConfigViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/19.
//

import Foundation
import UIKit

/// 组件配置界面。
///
/// 任意视图控制器实现该协议即可作为组件配置界面，无需继承 `WSPluginConfigViewController`。
/// 由 `WSPluginProvider.makeConfigViewController(plugin:)` 返回实例，返回 nil 表示不支持配置。
protocol WSPluginConfigurable: AnyObject {
    
    /// 正在配置的组件
    var plugin: WSPlugin { get }
    
    /// 配置变化回调。由外部在展示前设置，配置界面在用户点击完成时调用
    var didChangeConfigJSON: ((String?) -> Void)? { get set }
}

/// 组件配置视图控制器基类。
///
/// 提供统一的界面外壳：关闭 / 完成按钮、弹出尺寸与内容容器。
/// 子类在 `viewDidLoad` 中设置 `contentViewController` 提供配置内容，
/// 配置变化后调用 `updateConfigJSON(_:)` 记录改动；改动在点击完成时才回调外部保存，
/// 配置过程中的编辑不会实时反馈到组件。
class WSPluginConfigViewController: TPContainerViewController, WSPluginConfigurable {
    
    /// 正在配置的组件
    let plugin: WSPlugin
    
    /// 配置变化回调
    var didChangeConfigJSON: ((String?) -> Void)?
    
    /// 已保存的配置 JSON 字符串
    private(set) var configJSON: String?
    
    /// 配置过程中待提交的配置 JSON 字符串
    private var pendingConfigJSON: String?
    
    /// 是否存在待提交的修改
    private var hasPendingConfigJSON: Bool = false
    
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
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        preferredContentSize = AppLayout.Popover.extraLarge
        setupActionsBar(actions: [doneAction])
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    /// 内容区域避开底部操作栏
    override func contentViewFrame() -> CGRect {
        var frame = view.safeLayoutFrame()
        frame.size.height = max(frame.height - actionsBarHeight, 0.0)
        return frame
    }
    
    // MARK: - 配置
    /// 记录配置变化。改动暂存在界面内，点击完成时统一提交
    func updateConfigJSON(_ configJSON: String?) {
        pendingConfigJSON = configJSON
        hasPendingConfigJSON = true
    }
    
    /// 提交配置过程中的修改并回调外部保存。不会关闭界面
    func commitConfiguration() {
        guard hasPendingConfigJSON else {
            return
        }
        
        hasPendingConfigJSON = false
        let configJSON = pendingConfigJSON
        pendingConfigJSON = nil
        
        guard self.configJSON != configJSON else {
            return
        }
        
        self.configJSON = configJSON
        didChangeConfigJSON?(configJSON)
    }
    
    // MARK: - 完成
    override func clickDone() {
        /// 只有点击完成才保存配置并刷新组件
        commitConfiguration()
        super.clickDone()
    }
}

// MARK: - 类型化配置

extension WSPluginConfigViewController {
    
    /// 把当前配置解码为具体的配置模型
    func configuration<T: Decodable>(as type: T.Type) -> T? {
        guard let configJSON = configJSON else {
            return nil
        }
        
        return T.model(with: configJSON)
    }
    
    /// 用配置模型更新配置。只记录改动，点击完成时才回调外部保存
    ///
    /// 以当前配置为基准做字段级合并，仅覆盖模型认识的字段，
    /// 更高版本写入的字段会原样保留，避免低版本保存时丢失配置
    func updateConfiguration<T: Encodable>(_ configuration: T?) {
        guard let configuration = configuration else {
            updateConfigJSON(nil)
            return
        }
        
        updateConfigJSON(WSPluginConfigJSONMerger.merging(base: configJSON, model: configuration))
    }
}
