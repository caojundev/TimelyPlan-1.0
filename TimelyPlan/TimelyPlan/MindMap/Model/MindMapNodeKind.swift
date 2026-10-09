//
//  MindMapNodeKind.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/8.
//
//  节点类型层：一个节点「是什么」（文本 / 待办 / 图标 / 自定义），以及每种类型
//  随节点携带的额外数据（`content`）。
//
//  这一层只有纯数据，不含尺寸与绘制 ——
//  每种类型对应一个 `MindMapNodeLayer` 子类，由子类负责尺寸计算与绘制。
//
//  ── 与 MindMapNodeStyle 的分工 ───────────────────────────────────────
//    · MindMapNodeKind  —— 节点的**类型**：用哪个图层、带什么数据；
//    · MindMapNodeStyle —— 节点的**框型**：下划线 / 线框。
//  两者正交，可自由组合。
//

import UIKit

// MARK: - 类型标识

/// 节点类型标识。开放集合：新增类型只需定义一个新常量并注册对应图层。
public struct MindMapNodeKind: Hashable, RawRepresentable, ExpressibleByStringLiteral,
                              CustomStringConvertible {

    public let rawValue: String

    public init(rawValue: String) { self.rawValue = rawValue }
    public init(_ rawValue: String) { self.rawValue = rawValue }
    public init(stringLiteral value: String) { self.rawValue = value }

    public var description: String { rawValue }

    /// 文本节点：只有文本。也是所有未注册类型的回退类型。
    public static let text = MindMapNodeKind("text")
    /// 待办节点：文本左侧一个勾选框，随节点携带「是否完成」与勾选框样式。
    public static let todo = MindMapNodeKind("todo")
    /// 图标节点：文本左侧一个图标，随节点携带 `TPIcon` 与颜色。
    public static let icon = MindMapNodeKind("icon")
    /// 进度节点：文本左侧一个圆形进度环，随节点携带进度与颜色。
    public static let progress = MindMapNodeKind("progress")
}

// MARK: - 载荷

/// 节点携带的类型化额外数据，由对应类型的图层读取以配置自身。
///
/// 约束为 class：载荷是**可变的节点状态**（如勾选状态），图层直接读同一份引用，
/// 改完重绘即可反映最新值，不必重建模型。
public protocol MindMapNodeContent: AnyObject {

    /// 对应的节点类型。`MindMapNode` 据此决定用哪个图层子类。
    var kind: MindMapNodeKind { get }
}

// MARK: - 内置载荷

/// 待办勾选框样式。
public enum MindMapTodoCheckboxStyle {
    /// 圆角矩形。
    case roundedRect
    /// 圆形。
    case circle
}

/// 待办节点的载荷：是否完成 + 勾选框样式 + 勾选框颜色。
public final class MindMapTodoContent: MindMapNodeContent {

    public var kind: MindMapNodeKind { .todo }

    public var isDone: Bool

    /// 勾选框样式，默认圆角矩形。
    public var style: MindMapTodoCheckboxStyle

    /// 勾选框颜色；nil 时跟随节点所属分支色。
    public var tint: UIColor?

    public init(isDone: Bool = false,
                style: MindMapTodoCheckboxStyle = .roundedRect,
                tint: UIColor? = nil) {
        self.isDone = isDone
        self.style = style
        self.tint = tint
    }
}

/// 图标节点的载荷：图标 + 颜色。
///
/// 图标直接复用业务侧的 `TPIcon`（图片 / Emoji 文本），由 `MindMapIconNodeLayer`
/// 交给 `TPIconView` 渲染，因此图片图标与 Emoji 图标走同一套逻辑。
///
/// `tint` 为 nil 表示跟随节点当前的分支色 —— 换主题时图标不会「格格不入」。
public final class MindMapIconContent: MindMapNodeContent {

    public var kind: MindMapNodeKind { .icon }

    public var icon: TPIcon
    public var tint: UIColor?

    public init(icon: TPIcon, tint: UIColor? = nil) {
        self.icon = icon
        self.tint = tint
    }

    /// 便捷构造：资源图片名（如 "checkmark_circle_fill_24"）。
    public convenience init(imageName: String, tint: UIColor? = nil) {
        self.init(icon: TPIcon(name: imageName), tint: tint)
    }

    /// 便捷构造：Emoji / 文本。
    public convenience init(text: String, tint: UIColor? = nil) {
        self.init(icon: TPIcon(text: text), tint: tint)
    }
}

/// 进度节点的载荷：进度值 + 进度环颜色。
///
/// 由 `MindMapProgressNodeLayer` 交给 `TPCircleOutlineProgressView` 渲染。
///
/// `tint` 为 nil 表示跟随节点当前的分支色 —— 换主题时进度环不会「格格不入」。
public final class MindMapProgressContent: MindMapNodeContent {

    public var kind: MindMapNodeKind { .progress }

    /// 进度，范围 0～1（超出会被夹取）。
    public var progress: CGFloat

    /// 进度环颜色；nil 时跟随节点所属分支色。
    public var tint: UIColor?

    public init(progress: CGFloat, tint: UIColor? = nil) {
        self.progress = min(max(progress, 0), 1)
        self.tint = tint
    }
}
