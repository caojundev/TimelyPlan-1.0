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

        /// 选择器中的样式入口。共用同一个组件，只预设不同的分割线样式，
        /// 新增样式时随 `WSSeparatorStyle` 自动增加一行
        static let styleVariants: [WSPluginModuleVariant] = WSSeparatorStyle.allCases.map { style in
            return WSPluginModuleVariant(title: style.title,
                                         iconName: nil,
                                         configJSON: WSSeparatorConfiguration(style: style).jsonString())
        }

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .separator, size: size)
        }
    }
}
