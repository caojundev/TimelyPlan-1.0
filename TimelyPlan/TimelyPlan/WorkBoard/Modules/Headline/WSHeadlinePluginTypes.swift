import Foundation

extension WSPluginType {

    /// 标题模块的组件类型。
    enum Headline {

        /// 标题·自适应·标题描述：占满整行，高度按标题与描述的实际行数计算。
        static let flexibleTitleDescription = make("headlineFlexibleTitleDescription", .flexible)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            flexibleTitleDescription,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSHeadlinePluginProvider(), title: "Headline", subtitle: "Shows a title and description"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .headline, size: size)
        }
    }
}
