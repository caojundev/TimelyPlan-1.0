//
//  MindMapTheme.swift
//  MindMapKit
//
//  主题层：主题定义、内置主题、以及跟随系统明暗的主题管理器。
//
//  ── 分层（三件事各管各的）──────────────────────────────────────────
//    · MindMapTheme        —— 纯数据：一套主题 = 浅色 + 深色两份 MindMapPalette；
//    · MindMapThemeHost    —— 协议：任何「有 palette、且能上报环境明暗变化」的视图；
//    · MindMapThemeManager —— 行为：判定当前该用哪份配色，并下发给已接入的宿主。
//
//  管理器不认识 MindMapCanvasView，只认协议；宿主也不知道主题的存在，它只暴露一个
//  通用的 appearanceDidChange 回调。因此扩展方向都很轻：
//    · 加主题：构造一个 MindMapTheme（或加进 MindMapTheme.builtIn）；
//    · 加宿主：让视图实现 MindMapThemeHost 的两个成员；
//    · 不需要主题系统：直接给 canvas.palette 赋值即可，零成本。
//

import UIKit

// MARK: - 主题

/// 一套主题 = 同一设计语言下的浅色 / 深色两份配色。
///
/// 明暗成对放置，是为了避免「浅色主题配了深色分支色」这类错配。
/// 只想提供单侧配色时，把 `MindMapPalette` 直接交给宿主即可，不必经过主题管理器。
public struct MindMapTheme {

    public let id: String
    public let name: String
    public let light: MindMapPalette
    public let dark: MindMapPalette

    public init(id: String, name: String, light: MindMapPalette, dark: MindMapPalette) {
        self.id = id
        self.name = name
        self.light = light
        self.dark = dark
    }

    /// 取指定明暗下的配色。
    public func palette(for appearance: MindMapAppearance) -> MindMapPalette {
        switch appearance {
        case .light: return light
        case .dark: return dark
        }
    }
}

// MARK: - 内置主题

public extension MindMapTheme {

    /// 内置主题清单，可直接喂给设置界面。
    static let builtIn: [MindMapTheme] = [.classic, .paper, .mono]

    /// 经典：中性深灰 / 浅白底，饱和的五色分支。
    static let classic = MindMapTheme(
        id: "classic",
        name: "经典",
        light: MindMapPalette(
            background: gray(0.98),
            text: gray(0.13),
            rootText: gray(0.10),
            rootBorder: gray(0.62),
            branchColors: [rgb(0.13, 0.55, 0.27), rgb(0.78, 0.15, 0.20),
                           rgb(0.11, 0.42, 0.87), rgb(0.85, 0.50, 0.08),
                           rgb(0.48, 0.35, 0.82)]),
        dark: MindMapPalette(
            background: gray(0.17),
            text: .white,
            rootText: .white,
            rootBorder: gray(0.55),
            branchColors: [rgb(0.23, 0.69, 0.35), rgb(0.90, 0.22, 0.27),
                           rgb(0.18, 0.50, 0.98), rgb(0.95, 0.61, 0.22),
                           rgb(0.61, 0.50, 0.91)]))

    /// 纸感：米色纸面 / 暖墨底，低饱和的暖色分支。
    static let paper = MindMapTheme(
        id: "paper",
        name: "纸感",
        light: MindMapPalette(
            background: rgb(0.965, 0.949, 0.914),
            text: rgb(0.20, 0.18, 0.15),
            rootText: rgb(0.16, 0.14, 0.12),
            rootBorder: rgb(0.65, 0.61, 0.55),
            branchColors: [rgb(0.72, 0.28, 0.20), rgb(0.45, 0.50, 0.20),
                           rgb(0.16, 0.48, 0.48), rgb(0.80, 0.58, 0.16),
                           rgb(0.52, 0.32, 0.48)]),
        dark: MindMapPalette(
            background: rgb(0.145, 0.137, 0.125),
            text: rgb(0.92, 0.90, 0.86),
            rootText: rgb(0.95, 0.93, 0.89),
            rootBorder: rgb(0.55, 0.52, 0.47),
            branchColors: [rgb(0.87, 0.45, 0.36), rgb(0.66, 0.72, 0.38),
                           rgb(0.35, 0.72, 0.70), rgb(0.93, 0.74, 0.34),
                           rgb(0.74, 0.55, 0.72)]))

    /// 单色：纯白 / 纯黑，分支只用灰阶区分。
    static let mono = MindMapTheme(
        id: "mono",
        name: "单色",
        light: MindMapPalette(
            background: .white,
            text: gray(0.11),
            rootText: gray(0.08),
            rootBorder: gray(0.70),
            branchColors: [gray(0.20), gray(0.42), gray(0.62),
                           gray(0.32), gray(0.52)]),
        dark: MindMapPalette(
            background: gray(0.07),
            text: gray(0.95),
            rootText: gray(0.97),
            rootBorder: gray(0.45),
            branchColors: [gray(0.88), gray(0.68), gray(0.50),
                           gray(0.78), gray(0.60)]))
}

// MARK: - 宿主

/// 主题宿主：能接收配色、并能上报「所在环境明暗变了」的视图。
///
/// `MindMapCanvasView` 已经实现；任何持有 `palette` 的视图补上这两个成员即可接入。
public protocol MindMapThemeHost: UIView {

    var palette: MindMapPalette { get set }

    /// 环境明暗变化时由宿主自己调用，并把它当前的 trait 传上来
    /// （例如在 traitCollectionDidChange 里判断 hasDifferentColorAppearance 之后）。
    /// 接入期间由主题管理器占用。
    var appearanceDidChange: ((UITraitCollection) -> Void)? { get set }
}

// MARK: - 管理器

/// 主题管理器：判定当前该用哪份配色，并下发给所有已接入的宿主。
///
/// ```swift
/// let themes = MindMapThemeManager(theme: .classic)   // 默认跟随系统明暗
/// themes.attach(canvas)                               // 画布自动换肤
/// themes.onChange = { palette, appearance in
///     // 外部按钮 / 文字据此换色
/// }
/// themes.apply(.paper)                                // 手动换主题
/// themes.appearanceOverride = .dark                   // 强制深色（nil = 跟随系统）
/// ```
public final class MindMapThemeManager {

    // MARK: 状态

    /// 当前主题。
    public private(set) var theme: MindMapTheme

    /// 当前生效的明暗取向。
    public private(set) var appearance: MindMapAppearance

    /// 当前生效的配色。外部 UI 据此选色（配合 `appearance`）。
    public private(set) var palette: MindMapPalette

    /// 强制指定明暗；`nil`（默认）表示跟随环境。
    public var appearanceOverride: MindMapAppearance? {
        didSet {
            guard appearanceOverride != oldValue else { return }
            refresh()
        }
    }

    /// 配色变化后回调（换主题、切明暗、改覆盖都会触发；值没变则不会重复触发）。
    public var onChange: ((MindMapPalette, MindMapAppearance) -> Void)?

    /// 已接入宿主（弱引用，宿主销毁后自动脱落）。
    private let hosts = NSHashTable<UIView>.weakObjects()

    /// 最近一次从宿主环境读到的明暗。之所以由宿主上报而不是自己去读屏幕：宿主才是
    /// 真正在绘制的环境，取值确定，也不会猜错窗口。
    private var environmentAppearance: MindMapAppearance

    /// 上次已通知的（主题, 明暗），用于避免无变化时重复回调。
    private var notifiedThemeID: String?
    private var notifiedAppearance: MindMapAppearance?

    // MARK: 初始化

    public init(theme: MindMapTheme = .classic, appearanceOverride: MindMapAppearance? = nil) {
        let appearance = appearanceOverride ?? Self.screenAppearance()
        self.theme = theme
        self.appearanceOverride = appearanceOverride
        self.appearance = appearance
        self.environmentAppearance = appearance
        self.palette = theme.palette(for: appearance)
    }

    // MARK: 宿主

    /// 接入宿主：立即套用当前配色，并在其环境明暗变化时自动跟随。
    ///
    /// 管理器只持有弱引用；重复接入同一宿主是幂等的。
    public func attach(_ host: MindMapThemeHost) {
        hosts.add(host)
        host.appearanceDidChange = { [weak self] traits in
            self?.updateEnvironment(traits)
        }
        // 以宿主自己的环境为准（可能和初始化那一刻的屏幕环境不同）。
        updateEnvironment(host.traitCollection)
    }

    /// 断开宿主。会清空 `appearanceDidChange`（接入期间该回调归管理器使用）。
    public func detach(_ host: MindMapThemeHost) {
        hosts.remove(host)
        host.appearanceDidChange = nil
    }

    // MARK: 切换

    /// 切换主题并立即套用。
    public func apply(_ theme: MindMapTheme) {
        self.theme = theme
        refresh()
    }

    /// 重新套用当前主题。宿主环境变化时会自动调用，手动调用是幂等的。
    public func refresh() {
        let appearance = resolvedAppearance()
        self.appearance = appearance

        let palette = theme.palette(for: appearance)
        self.palette = palette

        for host in hosts.allObjects {
            (host as? MindMapThemeHost)?.palette = palette
        }

        guard theme.id != notifiedThemeID || appearance != notifiedAppearance else { return }
        notifiedThemeID = theme.id
        notifiedAppearance = appearance
        onChange?(palette, appearance)
    }

    // MARK: 明暗判定

    private func resolvedAppearance() -> MindMapAppearance {
        appearanceOverride ?? environmentAppearance
    }

    /// 记录宿主上报的环境并重新套用。
    private func updateEnvironment(_ traits: UITraitCollection) {
        environmentAppearance = traits.userInterfaceStyle == .dark ? .dark : .light
        refresh()
    }

    /// 初始化时还没有宿主，先用屏幕的环境兜底。
    private static func screenAppearance() -> MindMapAppearance {
        UIScreen.main.traitCollection.userInterfaceStyle == .dark ? .dark : .light
    }
}

// MARK: - 工具

private func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
    UIColor(red: red, green: green, blue: blue, alpha: 1)
}

private func gray(_ white: CGFloat) -> UIColor {
    UIColor(white: white, alpha: 1)
}
