//
//  TodoBoardPageFlowLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/1.
//

import Foundation
import UIKit

// MARK: - 增强版的流式布局
class TodoBoardPageFlowLayout: UICollectionViewFlowLayout {
    
    // MARK: - 装饰视图配置
    var sectionDecorationVisible: Bool = true {
        didSet { invalidateLayout() }
    }
    
    var sectionCornerRadius: CGFloat = 12 {
        didSet { invalidateLayout() }
    }
    
    var sectionColor: UIColor = UIColor.systemGray6 {
        didSet { invalidateLayout() }
    }
    
    var sectionEdgeInsets: UIEdgeInsets = .zero {
        didSet { invalidateLayout() }
    }
    
    // MARK: - 注册装饰视图
    private let sectionDecorationKind = "TodoBoardSectionDecoration"
    
    override init() {
        super.init()
        registerDecorationViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerDecorationViews()
    }
    
    private func registerDecorationViews() {
        register(
            TodoBoardSectionDecorationView.self,
            forDecorationViewOfKind: sectionDecorationKind
        )
    }
    
    // MARK: - Layout 生命周期
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        super.prepare()
        configureDefaultValues()
    }
    
    private func configureDefaultValues() {
        // 确保 collection view 的背景色透明，以显示装饰视图
        collectionView?.backgroundColor = .clear
    }
    
    // MARK: - 布局属性计算
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else {
            return nil
        }
        
        var allAttributes = super.layoutAttributesForElements(in: rect) ?? []
        let visibleHeight = collectionView.bounds.height
        let offsetY = collectionView.contentOffset.y
        
        // 处理装饰视图
        if sectionDecorationVisible {
            let decorationAttributes = createDecorationAttributes(
                for: allAttributes,
                in: collectionView
            )
            allAttributes.append(contentsOf: decorationAttributes)
        }
        
        // 处理 section header 和 footer
        processSectionHeadersAndFooters(
            in: &allAttributes,
            collectionView: collectionView,
            offsetY: offsetY,
            visibleHeight: visibleHeight
        )
        
        return allAttributes
    }
    
    override func layoutAttributesForDecorationView(
        ofKind elementKind: String,
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        
        guard elementKind == sectionDecorationKind,
              let collectionView = collectionView,
              sectionDecorationVisible else {
            return nil
        }
        
        let section = indexPath.section
        
        // 获取该 section 的布局属性
        guard let sectionAttributes = layoutAttributesForSection(section, in: collectionView) else {
            return nil
        }
        
        let attributes = TodoBoardSectionDecorationAttributes(
            forDecorationViewOfKind: sectionDecorationKind,
            with: IndexPath(item: 0, section: section)
        )
        
        // 计算装饰视图的 frame（包含 section 边距）
        let decorationFrame = calculateDecorationFrame(
            for: sectionAttributes,
            sectionInsets: sectionEdgeInsets
        )
        
        attributes.frame = decorationFrame
        attributes.zIndex = -1
        attributes.color = sectionColor
        attributes.cornerRadius = sectionCornerRadius
        attributes.isVisible = sectionDecorationVisible
        
        return attributes
    }
    
    // MARK: - 私有辅助方法
    
    private func createDecorationAttributes(
        for cellAttributes: [UICollectionViewLayoutAttributes],
        in collectionView: UICollectionView
    ) -> [UICollectionViewLayoutAttributes] {
        
        let sections = Set(cellAttributes.compactMap { $0.indexPath.section })
        var decorationAttributes: [UICollectionViewLayoutAttributes] = []
        
        for section in sections {
            let indexPath = IndexPath(item: 0, section: section)
            if let decorationAttr = layoutAttributesForDecorationView(
                ofKind: sectionDecorationKind,
                at: indexPath
            ) {
                decorationAttributes.append(decorationAttr)
            }
        }
        
        return decorationAttributes
    }
    
    private func layoutAttributesForSection(
        _ section: Int,
        in collectionView: UICollectionView
    ) -> (minY: CGFloat, maxY: CGFloat, minX: CGFloat, maxX: CGFloat)? {
        
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        guard numberOfItems > 0 else { return nil }
        
        var minX: CGFloat = .greatestFiniteMagnitude
        var maxX: CGFloat = -.greatestFiniteMagnitude
        var minY: CGFloat = .greatestFiniteMagnitude
        var maxY: CGFloat = -.greatestFiniteMagnitude
        
        // 遍历 section 中的所有 items
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: section)
            if let attributes = super.layoutAttributesForItem(at: indexPath) {
                minX = min(minX, attributes.frame.minX)
                maxX = max(maxX, attributes.frame.maxX)
                minY = min(minY, attributes.frame.minY)
                maxY = max(maxY, attributes.frame.maxY)
            }
        }
        
        // 包含 header 和 footer
        if let headerAttributes = super.layoutAttributesForSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: section)
        ) {
            minY = min(minY, headerAttributes.frame.minY)
        }
        
        if let footerAttributes = super.layoutAttributesForSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            at: IndexPath(item: 0, section: section)
        ) {
            maxY = max(maxY, footerAttributes.frame.maxY)
        }
        
        guard minX != .greatestFiniteMagnitude else { return nil }
        
        return (minY, maxY, minX, maxX)
    }
    
    private func calculateDecorationFrame(
        for sectionBounds: (minY: CGFloat, maxY: CGFloat, minX: CGFloat, maxX: CGFloat),
        sectionInsets: UIEdgeInsets
    ) -> CGRect {
        
        let x = sectionBounds.minX - sectionInsets.left
        let y = sectionBounds.minY - sectionInsets.top
        let width = (sectionBounds.maxX - sectionBounds.minX) + sectionInsets.left + sectionInsets.right
        let height = (sectionBounds.maxY - sectionBounds.minY) + sectionInsets.top + sectionInsets.bottom
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func processSectionHeadersAndFooters(
        in allAttributes: inout [UICollectionViewLayoutAttributes],
        collectionView: UICollectionView,
        offsetY: CGFloat,
        visibleHeight: CGFloat
    ) {
        var hasFooter = false
        
        // 处理已有的 attributes
        for (index, attr) in allAttributes.enumerated() {
            if attr.representedElementKind == UICollectionView.elementKindSectionFooter {
                hasFooter = true
                let footerAttr = attr.copy() as! UICollectionViewLayoutAttributes
                updateFooterPosition(footerAttr, offsetY: offsetY, visibleHeight: visibleHeight)
                allAttributes[index] = footerAttr
            }
        }
        
        // 补充缺失的 footer
        if !hasFooter {
            let numberOfSections = collectionView.numberOfSections
            for section in 0..<numberOfSections {
                let footerIndexPath = IndexPath(item: 0, section: section)
                if let footerAttr = super.layoutAttributesForSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionFooter,
                    at: footerIndexPath
                ) {
                    let footerAttrCopy = footerAttr.copy() as! UICollectionViewLayoutAttributes
                    updateFooterPosition(footerAttrCopy, offsetY: offsetY, visibleHeight: visibleHeight)
                    allAttributes.append(footerAttrCopy)
                }
            }
        }
    }
    
    // MARK: - Footer 吸底逻辑
    private func updateFooterPosition(
        _ footerAttr: UICollectionViewLayoutAttributes,
        offsetY: CGFloat,
        visibleHeight: CGFloat
    ) {
        let footerHeight = footerAttr.frame.height
        let originalFooterBottom = footerAttr.frame.maxY
        
        // 吸底目标位置：屏幕底部
        let stickyFooterBottom = offsetY + visibleHeight
        
        // 当 footer 原始底部超出屏幕底部时，固定在底部
        if originalFooterBottom > stickyFooterBottom {
            footerAttr.frame.origin.y = stickyFooterBottom - footerHeight
        }
        
        // 设置较高的 zIndex，确保 footer 在其他元素上方
        footerAttr.zIndex = 1024
    }
}

// MARK: - 装饰视图配置协议
protocol TodoBoardSectionDecorationConfigurable: AnyObject {
    var sectionDecorationVisible: Bool { get set }
    var sectionCornerRadius: CGFloat { get set }
    var sectionColor: UIColor { get set }
}

// MARK: - Section 装饰视图
final class TodoBoardSectionDecorationView: UICollectionReusableView {
    private var customColor: UIColor = .clear
    private var customCornerRadius: CGFloat = 0
    
    private let lineWidth = 1.2
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        clipsToBounds = true
        isUserInteractionEnabled = false
    }
    
    func configure(color: UIColor, cornerRadius: CGFloat) {
        self.customColor = color
        self.customCornerRadius = cornerRadius
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let roundedRect = bounds.inset(by: UIEdgeInsets(value: lineWidth / 2.0))
        let path = UIBezierPath(roundedRect: roundedRect, cornerRadius: customCornerRadius)
        path.lineWidth = lineWidth
        customColor.setStroke()
        customColor.withAlphaComponent(0.2).setFill()
        path.stroke()
        path.fill()
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        if let decorationAttributes = layoutAttributes as? TodoBoardSectionDecorationAttributes {
            configure(
                color: decorationAttributes.color,
                cornerRadius: decorationAttributes.cornerRadius
            )
        }
    }
}

// MARK: - 装饰视图自定义属性
final class TodoBoardSectionDecorationAttributes: UICollectionViewLayoutAttributes {
    var color: UIColor = .clear
    var cornerRadius: CGFloat = 0
    var isVisible: Bool = false
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! TodoBoardSectionDecorationAttributes
        copy.color = color
        copy.cornerRadius = cornerRadius
        copy.isVisible = isVisible
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TodoBoardSectionDecorationAttributes else {
            return false
        }
        return super.isEqual(object) &&
            color == other.color &&
            cornerRadius == other.cornerRadius &&
            isVisible == other.isVisible
    }
}
