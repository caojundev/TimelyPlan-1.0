import Foundation

extension WSPluginType {

    /// 正文模块的组件类型。
    enum Body {

        /// 正文·自适应·文本：占满整行，高度按文本的实际行数计算。
        static let flexibleText = make("bodyFlexibleText", .flexible)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            flexibleText,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSBodyPluginProvider(), title: "Body Text", subtitle: "Shows a paragraph of text"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .body, size: size)
        }
    }
}
