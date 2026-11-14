import Foundation

/// 组件类型。
///
/// 各模块的组件类型在 `<模块>/WS<模块>PluginTypes.swift` 中声明，
/// 本文件只负责聚合全部类型、按标识反查，以及提供通用展示能力。
///
/// 命名规则：模块 + 尺寸 + 内容。尺寸之后的词语说明该组件展示什么，
/// 用于区分同模块、同尺寸下的多种组件。
///
/// `rawValue` 参与持久化与组件标识，已发布的取值不可修改。
public struct WSPluginType: Hashable {

    /// 组件标识，与旧版枚举的 rawValue 一一对应。
    public let rawValue: String

    /// 所属模块。用于组件选择器分组，以及同模块三个尺寸之间的归类。
    public let module: WSPluginModule

    /// 该组件固定的尺寸。
    public let size: WSPluginSize

    init(_ rawValue: String, module: WSPluginModule, size: WSPluginSize) {
        self.rawValue = rawValue
        self.module = module
        self.size = size
    }
}

// MARK: - 固有属性

public extension WSPluginType {

    /// 组件标题，取自组件清单
    var title: String {
        return WSPluginCatalog.configuration(for: self)?.title ?? rawValue
    }

    /// 组件描述，取自组件清单。画廊等入口作为副标题展示，一句话说明展示内容。
    var subtitle: String {
        return WSPluginCatalog.configuration(for: self)?.subtitle ?? ""
    }
}

// MARK: - 全部类型

extension WSPluginType: CaseIterable {

    /// 全部组件类型，顺序 = 模块顺序 × 模块内声明顺序。
    public static let allCases: [WSPluginType] = [
        WSPluginType.MyDay.all,
        WSPluginType.Calendar.all,
        WSPluginType.Timeline.all,
        WSPluginType.Quadrant.all,
        WSPluginType.Countdown.all,
        WSPluginType.Focus.all,
        WSPluginType.Habit.all,
        WSPluginType.Goal.all,
        WSPluginType.TodoList.all,
        WSPluginType.TodoUserListTask.all,
        WSPluginType.TodoSmartListTask.all,
        WSPluginType.TodoTag.all,
        WSPluginType.TodoTagTask.all,
        WSPluginType.TodoFilter.all,
        WSPluginType.TodoFilterTask.all,
        WSPluginType.TodoCustomTask.all,
        WSPluginType.Headline.all,
        WSPluginType.Body.all,
        WSPluginType.Separator.all,
        WSPluginType.Action.all,
    ].flatMap { $0 }

    /// 标识索引，避免每次按标识反查都遍历数组。
    static let index: [String: WSPluginType] = {
        let index = Dictionary(allCases.map { ($0.rawValue, $0) },
                               uniquingKeysWith: { first, _ in first })
        assert(index.count == allCases.count, "存在重复的组件类型标识")
        return index
    }()
}

// MARK: - 编解码

extension WSPluginType: RawRepresentable {

    /// 按标识反查组件类型。未知标识返回 nil。
    public init?(rawValue: String) {
        guard let type = WSPluginType.index[rawValue] else {
            return nil
        }
        
        self = type
    }
}

extension WSPluginType: Codable {

    /// 与旧版枚举保持一致：直接编码为标识字符串
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        guard let type = WSPluginType(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "未知的组件类型：\(rawValue)")
        }
        
        self = type
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: - 组件配置

/// 单个组件的配置。
///
/// 组件类型取自提供者，标题与描述只存本地化 key，展示时再取值。
struct WSPluginConfiguration {

    /// 组件提供者
    let provider: WSPluginProvider

    /// 标题本地化 key
    let titleKey: String

    /// 描述本地化 key
    let subtitleKey: String

    /// 组件类型
    var type: WSPluginType {
        return provider.type
    }

    /// 组件标题
    var title: String {
        return resGetString(titleKey)
    }

    /// 组件描述
    var subtitle: String {
        return resGetString(subtitleKey)
    }

    init(_ provider: WSPluginProvider, title titleKey: String, subtitle subtitleKey: String) {
        self.provider = provider
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
    }
}

/// 组件清单。
///
/// 各模块的组件配置在 `<模块>/WS<模块>PluginTypes.swift` 中声明，本文件只做聚合；
/// 新增组件时只需在所属模块文件中追加类型常量与一行配置。
enum WSPluginCatalog {

    /// 全部组件配置，顺序与 `WSPluginType.allCases` 一致
    static let all: [WSPluginConfiguration] = [
        WSPluginType.MyDay.catalog,
        WSPluginType.Calendar.catalog,
        WSPluginType.Timeline.catalog,
        WSPluginType.Quadrant.catalog,
        WSPluginType.Countdown.catalog,
        WSPluginType.Focus.catalog,
        WSPluginType.Habit.catalog,
        WSPluginType.Goal.catalog,
        WSPluginType.TodoList.catalog,
        WSPluginType.TodoUserListTask.catalog,
        WSPluginType.TodoSmartListTask.catalog,
        WSPluginType.TodoTag.catalog,
        WSPluginType.TodoTagTask.catalog,
        WSPluginType.TodoFilter.catalog,
        WSPluginType.TodoFilterTask.catalog,
        WSPluginType.TodoCustomTask.catalog,
        WSPluginType.Headline.catalog,
        WSPluginType.Body.catalog,
        WSPluginType.Separator.catalog,
        WSPluginType.Action.catalog,
    ].flatMap { $0 }

    /// 按类型取回组件配置
    static func configuration(for type: WSPluginType) -> WSPluginConfiguration? {
        return configurations[type]
    }

    /// 类型索引，避免每次按类型查找都遍历数组
    private static let configurations: [WSPluginType: WSPluginConfiguration] = {
        return Dictionary(all.map { ($0.type, $0) }, uniquingKeysWith: { first, _ in first })
    }()
}
