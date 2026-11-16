import Foundation

extension WSPluginType {

    /// 文本模块的组件类型。
    enum Text {

        /// 文本·自适应·文本块：占满整行，高度按文本的实际行数计算。
        static let flexibleText = make("textFlexibleText", .flexible)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            flexibleText,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSTextPluginProvider(), title: "Text", subtitle: "Shows a paragraph of text"),
        ]

        /// 选择器中的样式入口。共用同一个文本组件，只预设不同的字体样式
        static let styleVariants: [WSPluginModuleVariant] = {
            let styles: [WSTextStyle] = [.title, .body]
            return styles.map { style in
                return WSPluginModuleVariant(title: style.title,
                                             iconName: nil,
                                             configJSON: WSTextConfiguration(textStyle: style).jsonString())
            }
        }()

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .text, size: size)
        }
    }
}
