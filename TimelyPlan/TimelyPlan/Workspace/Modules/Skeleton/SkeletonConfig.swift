//
//  SkeletonConfig.swift
//  Skeleton
//
//  骨架屏的全部可调参数。值语义（struct），每次 show 时传入一份拷贝，
//  互不影响；也可以直接改 Skeleton.config 做全局默认值。
//

import UIKit

public struct SkeletonConfig {

    // MARK: - 形状

    /// 占位块的形状
    public enum Shape: Int {
        /// 自动推断：优先继承视图自身的 layer.cornerRadius；
        /// UIImageView 且为正方形时按圆形处理；其余使用 `cornerRadius`
        case auto
        /// 直角矩形（仍带 `cornerRadius` 的圆角）
        case rectangle
        /// 正圆（半径 = 短边的一半）
        case circle
        /// 胶囊（半径 = 短边的一半）
        case capsule
    }

    // MARK: - 文本

    /// 多行文本的占位方式
    public enum TextLineMode {
        /// 整个控件画一个整块
        case block
        /// 按行拆分，最后一行按 `lastLineWidthRatio` 缩短（更接近真实文字）
        case lines
    }

    // MARK: - 动画

    public enum Animation: Equatable {
        case none
        /// 高光从左到右扫过
        case shimmer(duration: TimeInterval)
        /// 整体呼吸闪烁
        case pulse(duration: TimeInterval)
    }

    // MARK: - 外观

    /// 占位块底色
    public var baseColor: UIColor = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 0.18, alpha: 1)
            : UIColor(white: 0.93, alpha: 1)
    }

    /// 高光色（shimmer 用）
    public var highlightColor: UIColor = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 0.32, alpha: 1)
            : UIColor(white: 1.0, alpha: 1)
    }

    /// 默认圆角，会被视图自身的 skeletonCornerRadius / layer.cornerRadius 覆盖
    public var cornerRadius: CGFloat = 4

    /// 默认形状
    public var shape: Shape = .auto

    /// 占位块内缩，可让观感更“细”一点
    public var insets: UIEdgeInsets = .zero

    // MARK: - 文本细节

    public var textLineMode: TextLineMode = .lines

    /// 多行文本时，最后一行保留的宽度比例
    public var lastLineWidthRatio: CGFloat = 0.62

    /// 每一行占位块的上下留白（模拟行间距）
    public var textLineVerticalPadding: CGFloat = 1

    // MARK: - 动画参数

    public var animation: Animation = .none

    /// 尊重系统“减弱动态效果”，开启时自动降级为静态
    public var respectsReduceMotion: Bool = true

    // MARK: - 遍历规则

    /// 小于该尺寸的视图直接忽略（分割线、小圆点等噪音）
    public var minimumSize: CGSize = CGSize(width: 3, height: 3)

    /// 忽略 hidden / alpha ≈ 0 的视图
    public var ignoresHiddenViews: Bool = true

    /// 把占位块裁剪到骨架根视图的 bounds 内
    public var clipsToRootBounds: Bool = true

    /// 被标记的视图是否“吞掉”自己的子视图（true：父视图形成一个整块）
    public var markedViewIsLeaf: Bool = true

    /// 当整棵树里一个标记都没有时，自动把 UILabel / UIImageView 等“视觉叶子”当作占位块，
    /// 这样不写任何标记也能直接 `view.sk.show()`。
    public var fallbackToLeafViews: Bool = true

    // MARK: - 交互

    /// 骨架是否拦截点击。默认 false，让事件穿透到下面真实的视图
    public var blocksUserInteraction: Bool = false

    public init() {}

    public static let `default` = SkeletonConfig()
}
