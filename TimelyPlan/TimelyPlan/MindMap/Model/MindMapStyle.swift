//
//  MindMapStyle.swift
//  MindMapKit
//
//  样式层：所有可调参数集中于此，改风格不用碰布局或渲染代码。
//

import UIKit

// MARK: - 配色

/// 画布主题的明暗取向。外部 UI（按钮、图标、文字）据此选色即可与画布保持一致。
public enum MindMapAppearance {
    case light
    case dark
}

public struct MindMapPalette {
    public var background: UIColor
    public var text: UIColor
    public var rootText: UIColor
    /// 根节点圆角边框描边色。
    public var rootBorder: UIColor
    /// 一级分支依次取用的颜色，超出后循环。
    public var branchColors: [UIColor]

    public init(background: UIColor = UIColor(white: 0.17, alpha: 1),
                text: UIColor = .white,
                rootText: UIColor = .white,
                rootBorder: UIColor = UIColor(white: 0.55, alpha: 1),
                branchColors: [UIColor] = [
                    UIColor(red: 0.23, green: 0.69, blue: 0.35, alpha: 1), // 绿
                    UIColor(red: 0.90, green: 0.22, blue: 0.27, alpha: 1), // 红
                    UIColor(red: 0.18, green: 0.50, blue: 0.98, alpha: 1), // 蓝
                    UIColor(red: 0.95, green: 0.61, blue: 0.22, alpha: 1), // 橙
                    UIColor(red: 0.61, green: 0.50, blue: 0.91, alpha: 1)  // 紫
                ]) {
        self.background = background
        self.text = text
        self.rootText = rootText
        self.rootBorder = rootBorder
        self.branchColors = branchColors
    }

    public func branchColor(at index: Int) -> UIColor {
        guard !branchColors.isEmpty else { return text }
        return branchColors[((index % branchColors.count) + branchColors.count) % branchColors.count]
    }

    // MARK: 明暗取向（由背景色推导）

    /// 背景的相对亮度（WCAG 定义，0 = 纯黑，1 = 纯白）。
    ///
    /// 推导而非存储：背景色是唯一事实来源，改了背景就永远一致，不会出现
    /// 「背景换成浅色、却忘了同步标记」这类漂移。
    ///
    /// 说明：不考虑 alpha，假定背景是不透明的；无法解析色彩空间时按 0（深色）处理。
    public var backgroundLuminance: CGFloat {
        guard let space = CGColorSpace(name: CGColorSpace.sRGB),
              let converted = background.cgColor.converted(to: space,
                                                           intent: .defaultIntent,
                                                           options: nil),
              let components = converted.components,
              components.count >= 3 else { return 0 }

        func linearized(_ value: CGFloat) -> CGFloat {
            value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * linearized(components[0])
             + 0.7152 * linearized(components[1])
             + 0.0722 * linearized(components[2])
    }

    /// 由背景亮度推导的明暗取向，供外部 UI（按钮、图标、文字）对齐画布主题。
    /// 深浅主题各自的配色建议各存一份 palette，按 trait 切换 —— 这样 `background`
    /// 始终是具体颜色，推导结果一定准确。（若把 `.systemBackground` 这类动态颜色直接
    /// 放进 palette，它的 `cgColor` 会按当前环境解析，可能与绘制时的环境不一致。）
    public var appearance: MindMapAppearance {
        backgroundLuminance > Self.appearanceThreshold ? .light : .dark
    }

    /// 判定阈值：黑白前景对比度相等处的背景亮度（解 1.05/(L+0.05) = (L+0.05)/0.05，
    /// 得 L ≈ 0.179）。
    ///
    /// 用「对比度交叉点」而不是「亮度中点 0.5」：这个属性的用途是让外部挑按钮 /
    /// 文字颜色，阈值取在两种前景可读性相等的位置，推导结果才一定指向对比度更高的
    /// 那一种前景色（例如 #808080 会判为 `.light`，因为黑字对比度更高）。
    /// 若你的设计更想按「视觉上偏深还是偏浅」来分，用 `backgroundLuminance` 自己判。
    private static let appearanceThreshold: CGFloat = 0.179
}

// MARK: - 节点样式

/// 节点**框型**样式（决定外框怎么画、连线接在哪）。
///
/// 与 `MindMapNodeKind`（节点**类型**：用哪个图层、带什么数据）正交，可自由组合。
///
/// 布局层（内容块尺寸、连线锚点、折叠标记位置）与渲染层（画什么装饰）都只通过
/// `MindMapMetrics` 上的几何方法取值，因此新增框型只需要三处改动：
///   1. 在这里加一个 case；
///   2. 在 `contentInsets` / `connectionY` 里补上分支（switch 会强制提示，不会漏）；
///   3. 在 `MindMapNodeLayer.updateDecoration` 里补上绘制分支。
/// 布局引擎、画布、命中测试等调用方都不需要改动。
///
/// 新增节点**类型**则走另一条路径：加一个 `MindMapNodeLayer` 子类并注册即可，
/// 不必改这里的 switch。
public enum MindMapNodeStyle: Equatable {
    /// 下划线：文本下方一条横线，横线两端的端点就是连线的两个端点，
    /// 视觉上像是连线从横线延伸出来。
    case underline
    /// 线框：把节点框起来，连线接在左右两条边的中点（也就是节点垂直居中的位置）。
    case box
}

// MARK: - 度量

public struct MindMapMetrics: Equatable {

    /// 节点外观样式。
    public var nodeStyle: MindMapNodeStyle
    /// 同一父节点下相邻子节点之间的垂直间距。
    public var siblingSpacing: CGFloat
    /// 相邻层级之间的水平间距。
    public var levelSpacing: CGFloat
    /// 文本左右内边距。
    public var horizontalPadding: CGFloat
    /// 文本上下内边距。
    public var verticalPadding: CGFloat
    /// 折叠标记的尺寸。
    public var collapseMarkerSize: CGFloat
    /// 折叠标记与节点内容块右边缘的间距。标记整体位于节点**外侧**，
    /// 因此这部分宽度不再计入节点自身尺寸，而是占用层级间距。
    public var collapseMarkerSpacing: CGFloat
    /// 节点内容块的限定尺寸，由画布下发给图层子类的尺寸计算（超出即换行 / 收缩）。
    /// 某一维 ≤ 0 表示该方向不限制。默认宽度 = 文本上限 190 + 左右内边距 8 + 8。
    public var maxNodeSize: CGSize

    public var font: UIFont
    public var rootFont: UIFont

    /// 圆角描边框（`.box` 样式）在常规内容内边距（horizontalPadding /
    /// verticalPadding）之外**额外**增加的内边距，通常根节点使用。
    public var rootBorderPadding: UIEdgeInsets

    public var lineWidth: CGFloat
    public var rootLineWidth: CGFloat
    /// 折线拐角半径。
    public var cornerRadius: CGFloat

    /// `levelSpacing` 默认值 = 56：
    /// 折叠标记（间距 6 + 直径 11）现在位于节点外侧、占用层级间距，
    /// 因此比「标记画在节点内部」时需要的间距更大，同时节点自身也窄了 17pt，
    /// 两者相抵后节点盒之间的视觉留白与旧版基本一致。
    public init(siblingSpacing: CGFloat = 14,
                levelSpacing: CGFloat = 56,
                horizontalPadding: CGFloat = 8,
                verticalPadding: CGFloat = 4,
                collapseMarkerSize: CGFloat = 11,
                collapseMarkerSpacing: CGFloat = 0.0,
                maxNodeSize: CGSize = CGSize(width: 206, height: 0),
                font: UIFont = .systemFont(ofSize: 13),
                rootFont: UIFont = .systemFont(ofSize: 14, weight: .medium),
                rootBorderPadding: UIEdgeInsets = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14),
                lineWidth: CGFloat = 3,
                rootLineWidth: CGFloat = 4.5,
                cornerRadius: CGFloat = 8,
                nodeStyle: MindMapNodeStyle = .underline) {
        self.nodeStyle = nodeStyle
        self.siblingSpacing = siblingSpacing
        self.levelSpacing = levelSpacing
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.collapseMarkerSize = collapseMarkerSize
        self.collapseMarkerSpacing = collapseMarkerSpacing
        self.maxNodeSize = maxNodeSize
        self.font = font
        self.rootFont = rootFont
        self.rootBorderPadding = rootBorderPadding
        self.lineWidth = lineWidth
        self.rootLineWidth = rootLineWidth
        self.cornerRadius = cornerRadius
    }

    // MARK: 节点几何（全部由样式决定）

    /// 某个节点实际生效的样式。
    ///
    /// 根节点固定是线框（圆角矩形），连线从右边缘垂直中点引出，不随 `nodeStyle`
    /// 变化 —— 下层节点换样式时根节点保持原样。
    public func style(isRoot: Bool) -> MindMapNodeStyle {
        isRoot ? .box : nodeStyle
    }

    /// 与某个节点相连的连线线宽。
    /// 下划线样式要求「横线粗细与连线一致」，因此两者共用同一规则。
    public func edgeLineWidth(isRoot: Bool) -> CGFloat {
        isRoot ? rootLineWidth : lineWidth
    }

    /// 某个深度实际使用的字体。
    public func textFont(isRoot: Bool) -> UIFont {
        isRoot ? rootFont : font
    }

    /// 节点内容的默认内边距，也就是「内容块边缘 → 文本」的距离。
    ///
    /// 图层子类据此计算尺寸（`size(constrainedTo:...)`）与摆放文本
    /// （`updateContent(_:bounds:)`），两处取同一份内边距，因此不会出现
    /// 「量的时候按一套留白、画的时候按另一套」导致文本偏向一侧。
    public func contentInsets(isRoot: Bool) -> UIEdgeInsets {
        switch style(isRoot: isRoot) {
        case .underline:
            // 横线直接画在内容块底边上，不需要额外留白。
            return UIEdgeInsets(top: verticalPadding,
                                left: horizontalPadding,
                                bottom: verticalPadding,
                                right: horizontalPadding)
        case .box:
            // 线框离文本再远一圈：常规内容内边距 + 描边内边距。
            return UIEdgeInsets(top: verticalPadding + rootBorderPadding.top,
                                left: horizontalPadding + rootBorderPadding.left,
                                bottom: verticalPadding + rootBorderPadding.bottom,
                                right: horizontalPadding + rootBorderPadding.right)
        }
    }

    /// 连线接入 / 离开节点时的纵坐标。
    ///
    /// - `.underline`：取内容块底边，也就是横线所在的位置 —— 横线两端正好是连线的端点，
    ///   看上去连线像是从横线延伸出来的。
    /// - `.box`：取内容块垂直中心，即线框左右两条边的中点（根节点即从此处引出连线）。
    public func connectionY(in frame: CGRect, isRoot: Bool) -> CGFloat {
        switch style(isRoot: isRoot) {
        case .underline: return frame.maxY
        case .box: return frame.midY
        }
    }

    /// 连线离开节点的锚点（内容坐标）。
    public func anchorOut(in frame: CGRect, isRoot: Bool) -> CGPoint {
        CGPoint(x: frame.maxX, y: connectionY(in: frame, isRoot: isRoot))
    }

    /// 连线接入节点的锚点（内容坐标）。
    public func anchorIn(in frame: CGRect, isRoot: Bool) -> CGPoint {
        CGPoint(x: frame.minX, y: connectionY(in: frame, isRoot: isRoot))
    }

    /// 节点文本区域下方留白：无子节点时不需要为展开标记预留空间，
    /// 但为了视觉基线统一，统一保留一小段。
    public var textBottomInset: CGFloat { verticalPadding }

    /// 展开 / 折叠标记圆的中心：位于节点内容块右边缘的**外侧**，纵向与连线对齐
    /// （所以它正好挂在连线上）。
    ///
    /// 布局、渲染（MindMapNodeLayer）与命中测试（MindMapCanvasView）共用这一份几何，
    /// 避免三处各算一遍导致标记与可点区域对不上。
    ///
    /// - Parameters:
    ///   - frame: 节点内容块在内容坐标系中的位置与尺寸。
    ///   - isRoot: 根节点固定用线框样式，标记的纵向位置随之取内容块垂直中心。
    public func collapseMarkerCenter(forNodeFrame frame: CGRect, isRoot: Bool) -> CGPoint {
        CGPoint(x: frame.maxX + collapseMarkerSpacing + collapseMarkerSize / 2,
                y: connectionY(in: frame, isRoot: isRoot))
    }
}
