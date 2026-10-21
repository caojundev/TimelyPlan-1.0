//
//  SkeletonBuilder.swift
//  Skeleton
//
//  核心算法：深度优先遍历视图树，收集所有 isSkeletonable 的子视图，
//  并统一转换到「骨架根视图」的坐标系，产出一组圆角矩形描述。
//  这里只做纯粹的计算，不碰任何 layer，方便单测。
//

import UIKit

/// 一个占位块（坐标已转换到 root 坐标系）
struct SkeletonPlaceholder {
    let frame: CGRect
    let cornerRadius: CGFloat
}

enum SkeletonBuilder {

    /// 最大遍历深度，防御性限制，避免异常视图树导致栈溢出
    private static let maxDepth = 32

    // MARK: - 入口

    static func build(root: UIView, config: SkeletonConfig) -> [SkeletonPlaceholder] {
        // 根视图自己被标记：整棵子树只画一块（例如 imgView.sk.show()）
        if root.skAttributesIfLoaded?.isSkeletonable == true {
            return makePlaceholders(for: root, root: root, config: config)
        }

        var placeholders: [SkeletonPlaceholder] = []
        var hasExplicitMark = false

        collect(in: root,
                root: root,
                config: config,
                depth: 0,
                hasExplicitMark: &hasExplicitMark,
                into: &placeholders)

        // 一个标记都没有时，退化为“自动识别视觉叶子”，实现真正的零标记一行调用
        if placeholders.isEmpty, config.fallbackToLeafViews, !hasExplicitMark {
            collectLeaves(in: root, root: root, config: config, depth: 0, into: &placeholders)
        }

        return placeholders
    }

    // MARK: - 第一遍：按标记收集

    private static func collect(in container: UIView,
                                root: UIView,
                                config: SkeletonConfig,
                                depth: Int,
                                hasExplicitMark: inout Bool,
                                into result: inout [SkeletonPlaceholder]) {
        guard depth < maxDepth else { return }

        for subview in container.subviews {
            // 跳过自己的骨架层，避免递归
            if subview is SkeletonHostView { continue }
            guard shouldVisit(subview, config: config) else { continue }

            if subview.skAttributesIfLoaded?.isSkeletonable == true {
                hasExplicitMark = true
                result.append(contentsOf: makePlaceholders(for: subview, root: root, config: config))
                // 默认：标记即叶子，不再往下找
                if config.markedViewIsLeaf { continue }
            }

            collect(in: subview,
                    root: root,
                    config: config,
                    depth: depth + 1,
                    hasExplicitMark: &hasExplicitMark,
                    into: &result)
        }
    }

    // MARK: - 第二遍：自动识别视觉叶子

    private static func collectLeaves(in container: UIView,
                                      root: UIView,
                                      config: SkeletonConfig,
                                      depth: Int,
                                      into result: inout [SkeletonPlaceholder]) {
        guard depth < maxDepth else { return }

        for subview in container.subviews {
            if subview is SkeletonHostView { continue }
            guard shouldVisit(subview, config: config) else { continue }

            if isVisualLeaf(subview) {
                result.append(contentsOf: makePlaceholders(for: subview, root: root, config: config))
            } else {
                collectLeaves(in: subview, root: root, config: config, depth: depth + 1, into: &result)
            }
        }
    }

    private static func isVisualLeaf(_ view: UIView) -> Bool {
        if view is UILabel || view is UIImageView || view is UITextField || view is UITextView {
            return true
        }
        if view is UIControl { // UIButton / UISwitch / UISlider / UISegmentedControl ...
            return true
        }
        if view is UIActivityIndicatorView || view is UIPageControl || view is UIStepper {
            return true
        }
        // 没有子视图、但自己有底色/边框的普通视图，也当作一个色块
        if view.subviews.isEmpty {
            if let background = view.backgroundColor, background.cgColor.alpha > 0.01 { return true }
            if view.layer.borderWidth > 0 { return true }
        }
        return false
    }

    // MARK: - 单个视图 -> 占位矩形

    private static func shouldVisit(_ view: UIView, config: SkeletonConfig) -> Bool {
        if config.ignoresHiddenViews, view.isHidden || view.alpha < 0.01 { return false }
        if view.skAttributesIfLoaded?.isExcluded == true { return false }
        return true
    }

    private static func makePlaceholders(for view: UIView,
                                         root: UIView,
                                         config: SkeletonConfig) -> [SkeletonPlaceholder] {
        let attributes = view.skAttributesIfLoaded
        let insets = attributes?.insets ?? config.insets

        let rawRects: [CGRect]
        if let label = view as? UILabel {
            rawRects = labelRects(label: label, root: root, config: config)
        } else {
            // 关键：坐标统一转换到 root，无论嵌套多深、是否在 scrollView 里、是否有 transform
            rawRects = [view.convert(view.bounds, to: root)]
        }

        return rawRects.compactMap { raw in
            var rect = raw.inset(by: insets)
            if config.clipsToRootBounds {
                rect = rect.intersection(root.bounds)
            }
            guard !rect.isNull,
                  rect.width >= config.minimumSize.width,
                  rect.height >= config.minimumSize.height else { return nil }

            return SkeletonPlaceholder(frame: rect,
                                       cornerRadius: cornerRadius(for: view, rect: rect, config: config))
        }
    }

    // MARK: - 圆角

    private static func cornerRadius(for view: UIView, rect: CGRect, config: SkeletonConfig) -> CGFloat {
        let limit = min(rect.width, rect.height) / 2
        if let custom = view.skAttributesIfLoaded?.cornerRadius {
            return min(max(custom, 0), limit)
        }
        switch view.skAttributesIfLoaded?.shape ?? config.shape {
        case .circle, .capsule:
            return limit
        case .rectangle:
            return min(config.cornerRadius, limit)
        case .auto:
            if view.layer.cornerRadius > 0 {
                return min(view.layer.cornerRadius, limit)
            }
            if view is UIImageView, abs(rect.width - rect.height) <= 1 {
                return limit
            }
            return min(config.cornerRadius, limit)
        }
    }

    // MARK: - UILabel 的按行拆分

    private static func labelRects(label: UILabel, root: UIView, config: SkeletonConfig) -> [CGRect] {
        let bounds = label.bounds
        guard bounds.width > 0, bounds.height > 0 else { return [] }

        let lineHeight = max(label.font.lineHeight, 1)
        let padding = min(config.textLineVerticalPadding, lineHeight * 0.2)

        let isMultiline = config.textLineMode == .lines
            && label.numberOfLines != 1
            && bounds.height > lineHeight * 1.6

        guard isMultiline else {
            // 单行：高度收敛到一行，避免出现一块“胖胖的”大色块
            let height = min(bounds.height, lineHeight)
            let width = measuredWidth(of: label, maxWidth: bounds.width)
            let y = bounds.minY + (bounds.height - height) / 2
            let x = alignedX(for: label, width: width, in: bounds)
            let rect = CGRect(x: x, y: y + padding, width: width, height: max(height - padding * 2, 1))
            return [label.convert(rect, to: root)]
        }

        // 上限 20 行，防御异常大的 frame
        let lineCount = min(20, max(1, Int((bounds.height / lineHeight).rounded())))
        var rects: [CGRect] = []
        rects.reserveCapacity(lineCount)

        for index in 0..<lineCount {
            let isLast = (index == lineCount - 1) && lineCount > 1
            let width = isLast
                ? bounds.width * min(max(config.lastLineWidthRatio, 0.1), 1)
                : bounds.width
            let y = CGFloat(index) * lineHeight
            let height = min(lineHeight, bounds.height - y)
            guard height > 0 else { break }

            let x = alignedX(for: label, width: width, in: bounds)
            let rect = CGRect(x: x,
                              y: bounds.minY + y + padding,
                              width: width,
                              height: max(height - padding * 2, 1))
            rects.append(label.convert(rect, to: root))
        }
        return rects
    }

    /// 有真实文案时按文案宽度画，视觉上更自然；没文案（骨架场景常见）就用整行
    private static func measuredWidth(of label: UILabel, maxWidth: CGFloat) -> CGFloat {
        guard let text = label.text, !text.isEmpty else { return maxWidth }
        let size = label.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        return min(maxWidth, size.width.rounded(.up))
    }

    private static func alignedX(for label: UILabel, width: CGFloat, in bounds: CGRect) -> CGFloat {
        switch label.textAlignment {
        case .right:
            return bounds.minX + bounds.width - width
        case .center:
            return bounds.minX + (bounds.width - width) / 2
        default:
            return bounds.minX
        }
    }
}
