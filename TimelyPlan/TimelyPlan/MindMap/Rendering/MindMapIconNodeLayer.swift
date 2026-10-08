//
//  MindMapIconNodeLayer.swift
//  MindMapKit
//
//  图标节点图层：文本 + 左侧图标（SF Symbols 或资源图）。
//  图标来源与颜色从节点的 `content` 读取；颜色缺省时跟随分支色。
//

import Foundation
import UIKit
import QuartzCore

open class MindMapIconNodeLayer: MindMapTextNodeLayer {
    
    public override class var kind: MindMapNodeKind { .icon }

    // MARK: 样式（该类型自己的可调参数）

    /// 图标边长。
    open class var iconSize: CGFloat { 16 }
    /// 图标与文本之间的间距。
    open class var accessorySpacing: CGFloat { 6 }

    private let iconLayer = CALayer()

    // MARK: 初始化

    public required init(palette: MindMapPalette) {
        super.init(palette: palette)
        iconLayer.contentsGravity = .resizeAspect
        addSublayer(iconLayer)
    }

    public override init(layer: Any) {
        super.init(layer: layer)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: 尺寸（自定义：文本 + 图标）

    open override class func size(constrainedTo constraint: CGSize,
                                  text: String,
                                  content: MindMapNodeContent?,
                                  metrics: MindMapMetrics,
                                  isRoot: Bool) -> CGSize {
        let accessory = CGSize(width: iconSize, height: iconSize)
        let insets = metrics.contentInsets(isRoot: isRoot)

        // 限定宽度先扣掉图标占位，文本在剩余空间里换行。
        var textConstraint = constraint
        if textConstraint.width > 0 {
            textConstraint.width -= accessory.width + accessorySpacing
        }
        let textPart = super.size(constrainedTo: textConstraint, text: text,
                                  content: content, metrics: metrics, isRoot: isRoot)

        return CGSize(
            width: textPart.width + accessory.width + accessorySpacing,
            height: max(textPart.height, accessory.height + insets.top + insets.bottom))
    }

    // MARK: 内容

    open override func leadingTextInset(metrics: MindMapMetrics,
                                        content: MindMapNodeContent?,
                                        isRoot: Bool) -> CGFloat {
        Self.iconSize + Self.accessorySpacing
    }

    open override func updateContent(_ node: MindMapNodeLayout, bounds: CGRect) {
        super.updateContent(node, bounds: bounds)

        guard let icon = node.content as? MindMapIconContent,
              let image = Self.image(for: icon.source) else {
            iconLayer.contents = nil
            return
        }

        // 取整到整点，配合 contentsScale 让图标落到整像素上，避免虚边。
        let side = min(Self.iconSize, bounds.height).rounded()
        let insets = metrics.contentInsets(isRoot: node.isRoot)
        iconLayer.bounds = CGRect(x: 0, y: 0, width: side, height: side)
        iconLayer.position = CGPoint(x: insets.left + side / 2, y: bounds.height / 2)

        let tint = icon.tint ?? node.color
        iconLayer.contents = Self.tintedImage(image, tint: tint,
                                              size: iconLayer.bounds.size)
    }

    private static func image(for source: MindMapIconSource) -> UIImage? {
        switch source {
        case .system(let name): return UIImage(systemName: name)
        case .asset(let name): return UIImage(named: name)
        }
    }

    /// 把图标按指定颜色光栅化成位图。
    ///
    /// 不能直接把 `image.withTintColor(...).cgImage` 交给图层：着色对（模板）图片是
    /// **绘制时**生效的，`cgImage` 取到的始终是未着色的原始位图 —— 落到 CALayer 上
    /// 就会画成默认的黑色。所以这里显式绘制一次，把颜色烤进位图。
    ///
    /// - Note: 一律按模板方式绘制，即用图片的 alpha 形状填色。因此资源图也会被
    ///   着色成单色，这正是「图标节点」想要的效果（颜色由载荷或分支色决定）。
    private static func tintedImage(_ image: UIImage,
                                    tint: UIColor,
                                    size: CGSize) -> CGImage? {
        guard size.width > 0, size.height > 0 else { return nil }
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            tint.setFill()
            image.withRenderingMode(.alwaysTemplate)
                .draw(in: CGRect(origin: .zero, size: size))
        }.cgImage
    }
}
