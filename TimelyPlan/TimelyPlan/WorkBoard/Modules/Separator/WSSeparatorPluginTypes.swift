import Foundation

extension WSPluginType {

    /// 分割线模块的组件类型。
    enum Separator {

        /// 分割线·自适应·分割线：占满整行，使用固定高度。
        static let flexibleLine = make("separatorFlexibleLine", .flexible)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            flexibleLine,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSSeparatorPluginProvider(), title: "Separator", subtitle: "Shows a divider line"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .separator, size: size)
        }
    }
}
