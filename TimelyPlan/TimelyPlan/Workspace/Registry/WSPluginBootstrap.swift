// 文件：App/WSPluginBootstrap.swift

enum WSPluginBootstrap {

    /// 注册所有组件 Provider。必须在 App 启动时调用一次。
    static func registerAll() {
        let registry = WSPluginRegistry.shared
        
        // 倒数日
        registry.register(WSCountdownSmallSelectedPluginProvider())
        registry.register(WSCountdownMediumRecentPluginProvider())
    }
}
