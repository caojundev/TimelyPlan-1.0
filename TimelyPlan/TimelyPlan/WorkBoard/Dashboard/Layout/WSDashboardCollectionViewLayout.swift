//
//  WSDashboardCollectionViewLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/19.
//

import Foundation
import UIKit

// MARK: - 工作台布局
/// 工作台自定义流式布局。
///
/// 在左对齐流式布局的基础上，为「未铺满整行」的空白区域补上装饰视图。
/// 例如一行中只有一个小尺寸组件（后面跟着中尺寸组件），右侧会空出一个网格单元，
/// 此时用一个同尺寸的空白装饰视图占位，避免视觉上出现无意义的空洞。
final class WSDashboardCollectionViewLayout: UICollectionViewLeftAlignedLayout {
    
    /// 空白占位装饰视图的复用标识
    static let gapDecorationKind = "WSDashboardGapDecoration"
    
    /// 空白占位装饰视图的背景色
    var gapColor: UIColor = .secondarySystemGroupedBackground {
        didSet {
            invalidateLayout()
        }
    }
    
    /// 空白占位装饰视图的圆角，默认与小尺寸组件保持一致
    var gapCornerRadius: CGFloat = 16.0 {
        didSet {
            invalidateLayout()
        }
    }
    
    /// 空白占位装饰视图的布局属性缓存，key 为装饰视图的 indexPath
    private var gapLayoutAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    
    /// 点击空白占位装饰视图的回调，参数为该空白前一个条目的索引
    var gapDecorationTapHandler: ((IndexPath) -> Void)?
    
    /// 是否隐藏空白占位装饰视图（拖动排序期间隐藏）
    private(set) var isGapDecorationHidden: Bool = false
    
    /// 设置空白占位装饰视图的显隐。
    ///
    /// 隐藏时直接清空缓存，不触发整体失效，避免拖动过程中单元格被重新应用布局属性
    /// 而导致被隐藏的拖动单元格短暂显示；恢复显示由调用方主动失效布局重建装饰视图。
    func setGapDecorationsHidden(_ isHidden: Bool) {
        guard isGapDecorationHidden != isHidden else {
            return
        }
        
        isGapDecorationHidden = isHidden
        if isHidden {
            gapLayoutAttributes.removeAll()
        }
    }
    
    override init() {
        super.init()
        registerGapDecorationView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerGapDecorationView()
    }
    
    private func registerGapDecorationView() {
        register(WSDashboardGapDecorationView.self,
                 forDecorationViewOfKind: Self.gapDecorationKind)
    }
    
    override func invalidateLayout() {
        gapLayoutAttributes.removeAll()
        super.invalidateLayout()
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        /// 仅在容器尺寸变化时重算，滚动引起的偏移变化不触发失效，避免频繁重算
        guard let collectionView = collectionView else {
            return super.shouldInvalidateLayout(forBoundsChange: newBounds)
        }
        
        return newBounds.size != collectionView.bounds.size
    }
    
    override func prepare() {
        super.prepare()
        prepareGapLayoutAttributes()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect) ?? []
        /// 追加与 rect 相交的空白占位装饰视图
        let gapAttributes = gapLayoutAttributes.values.filter { $0.frame.intersects(rect) }
        return attributes + gapAttributes
    }
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String,
                                                    at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard elementKind == Self.gapDecorationKind else {
            return nil
        }
        
        return gapLayoutAttributes[indexPath]
    }
    
    // MARK: - 空白占位计算
    /// 以分区内全部条目的左对齐结果反推每行的剩余宽度，并为剩余宽度补上空白装饰视图
    private func prepareGapLayoutAttributes() {
        gapLayoutAttributes.removeAll()
        
        /// 拖动排序期间不生成空白占位视图
        guard !isGapDecorationHidden, let collectionView = collectionView else {
            return
        }
        
        let sectionCount = collectionView.numberOfSections
        for section in 0..<sectionCount {
            let itemCount = collectionView.numberOfItems(inSection: section)
            guard itemCount > 0 else {
                continue
            }
            
            var cellAttributes: [UICollectionViewLayoutAttributes] = []
            cellAttributes.reserveCapacity(itemCount)
            for item in 0..<itemCount {
                guard let attributes = layoutAttributesForItem(at: IndexPath(item: item, section: section)),
                      attributes.frame.width > 0.0 else {
                    continue
                }
                
                cellAttributes.append(attributes)
            }
            
            /// 网格单元边长等于分区内最窄条目的宽度（即小尺寸组件的宽度）
            guard let unitLength = cellAttributes.map({ $0.frame.width }).min(),
                  unitLength > 0.0 else {
                continue
            }
            
            let inset = sectionInset(forSection: section)
            let spacing = interitemSpacing(forSection: section)
            /// 内容区域右边界，超出该边界的部分不属于可补位范围
            let contentMaxX = collectionView.bounds.width - inset.right
            
            let rows = groupRows(cellAttributes)
            for (rowIndex, row) in rows.enumerated() {
                guard let first = row.first else {
                    continue
                }
                
                let rowMinY = row.map({ $0.frame.minY }).min() ?? first.frame.minY
                let rowMaxY = row.map({ $0.frame.maxY }).max() ?? first.frame.maxY
                let occupiedMaxX = row.map({ $0.frame.maxX }).max() ?? first.frame.maxX
                /// 空白区域左侧紧邻的条目，点击空白时用于定位「在哪个插件之后」新增
                let precedingIndexPath = row.max(by: { $0.frame.maxX < $1.frame.maxX })?.indexPath
                
                /// 从行内最后一个条目的右侧开始补位，剩余宽度不足半个单元时不补，避免出现窄条
                var gapMinX = occupiedMaxX + spacing
                while contentMaxX - gapMinX > unitLength * 0.5 {
                    let gapWidth = min(unitLength, contentMaxX - gapMinX)
                    let attributes = WSDashboardGapDecorationAttributes(
                        forDecorationViewOfKind: Self.gapDecorationKind,
                        with: IndexPath(item: rowIndex, section: section)
                    )
                    attributes.frame = CGRect(x: gapMinX,
                                              y: rowMinY,
                                              width: gapWidth,
                                              height: rowMaxY - rowMinY)
                    /// 低于条目层级，仅作为背景占位
                    attributes.zIndex = -1
                    attributes.gapColor = gapColor
                    attributes.gapCornerRadius = gapCornerRadius
                    attributes.previousItemIndexPath = precedingIndexPath
                    gapLayoutAttributes[attributes.indexPath] = attributes
                    
                    gapMinX += gapWidth + spacing
                }
            }
        }
    }
    
    /// 按行分组。左对齐布局只调整 x，因此同一行条目的 minY 相同
    private func groupRows(_ attributes: [UICollectionViewLayoutAttributes]) -> [[UICollectionViewLayoutAttributes]] {
        let sortedAttributes = attributes.sorted {
            if abs($0.frame.minY - $1.frame.minY) > 0.5 {
                return $0.frame.minY < $1.frame.minY
            }
            
            return $0.frame.minX < $1.frame.minX
        }
        
        var rows: [[UICollectionViewLayoutAttributes]] = []
        for attributes in sortedAttributes {
            if let rowMinY = rows.last?.first?.frame.minY,
               abs(rowMinY - attributes.frame.minY) <= 0.5 {
                rows[rows.count - 1].append(attributes)
            } else {
                rows.append([attributes])
            }
        }
        
        return rows
    }
    
    /// 分区内边距。优先取代理回调，保证与条目尺寸的来源一致
    private func sectionInset(forSection section: Int) -> UIEdgeInsets {
        guard let collectionView = collectionView,
              let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else {
            return self.sectionInset
        }
        
        return delegate.collectionView?(collectionView,
                                        layout: self,
                                        insetForSectionAt: section) ?? self.sectionInset
    }
    
    /// 分区内条目间距。优先取代理回调，保证与条目尺寸的来源一致
    private func interitemSpacing(forSection section: Int) -> CGFloat {
        guard let collectionView = collectionView,
              let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else {
            return self.minimumInteritemSpacing
        }
        
        return delegate.collectionView?(collectionView,
                                        layout: self,
                                        minimumInteritemSpacingForSectionAt: section) ?? self.minimumInteritemSpacing
    }
}

// MARK: - 空白占位装饰视图
/// 空白占位装饰视图。用于填充小尺寸组件后剩余的空白网格单元，点击后可在对应位置添加组件。
final class WSDashboardGapDecorationView: UICollectionReusableView {
    
    /// 虚线边框
    private lazy var borderLayer: TPBorderLayer = {
        let borderLayer = TPBorderLayer()
        /// 灰色虚线
        borderLayer.lineColor = .systemGray3
        borderLayer.lineDashValues = [4.0, 4.0]
        /// 内缩半个线宽（TPBorderLayer 线宽固定为 1.0），避免描边被裁掉
        borderLayer.padding = UIEdgeInsets(value: 0.5)
        return borderLayer
    }()
    
    /// 空白区域前一个条目的索引
    private var previousItemIndexPath: IndexPath?
    
    /// 点击手势
    private lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    }()
    
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
        /// 支持点击空白区域，在对应位置添加组件
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGesture)
        layer.addSublayer(borderLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        /// 边框圆角与占位视图保持一致
        borderLayer.cornerRadius = layer.cornerRadius
        borderLayer.frame = bounds
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        guard let attributes = layoutAttributes as? WSDashboardGapDecorationAttributes else {
            return
        }
        
        previousItemIndexPath = attributes.previousItemIndexPath
        backgroundColor = attributes.gapColor
        layer.cornerRadius = attributes.gapCornerRadius
        layer.cornerCurve = .continuous
        /// 圆角变化后重绘边框路径
        setNeedsLayout()
    }
    
    /// 点击空白占位视图，通知布局对象所在空白对应的前一个条目
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let indexPath = previousItemIndexPath,
              let layout = enclosingDashboardLayout else {
            return
        }
        
        layout.gapDecorationTapHandler?(indexPath)
    }
    
    /// 向上查找所属的工作台布局
    private var enclosingDashboardLayout: WSDashboardCollectionViewLayout? {
        var currentView = superview
        while let view = currentView {
            if let collectionView = view as? UICollectionView {
                return collectionView.collectionViewLayout as? WSDashboardCollectionViewLayout
            }
            
            currentView = view.superview
        }
        
        return nil
    }
}

// MARK: - 空白占位装饰视图布局属性
/// 携带空白占位视图外观配置的布局属性
final class WSDashboardGapDecorationAttributes: UICollectionViewLayoutAttributes {
    
    var gapColor: UIColor = .clear
    var gapCornerRadius: CGFloat = 0.0
    
    /// 空白区域左侧紧邻条目的索引。点击空白时用于定位「在哪个插件之后」添加组件
    var previousItemIndexPath: IndexPath?
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! WSDashboardGapDecorationAttributes
        copy.gapColor = gapColor
        copy.gapCornerRadius = gapCornerRadius
        copy.previousItemIndexPath = previousItemIndexPath
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? WSDashboardGapDecorationAttributes else {
            return false
        }
        
        return super.isEqual(object) &&
            gapColor == other.gapColor &&
            gapCornerRadius == other.gapCornerRadius &&
            previousItemIndexPath == other.previousItemIndexPath
    }
}
