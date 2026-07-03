//
//  CalendarYearCollectionLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/3.
//

import Foundation

// MARK: - 自定义年日历布局
class CalendarYearCollectionLayout: UICollectionViewFlowLayout {
    
    // MARK: - 公开属性
    var minimumItemsPerRow: Int = 3 {
        didSet { if oldValue != minimumItemsPerRow { needsLayout = true } }
    }
    var maximumItemsPerRow: Int = 4 {
        didSet { if oldValue != maximumItemsPerRow { needsLayout = true } }
    }
    var preferredMinimumSpacing: CGFloat = 4.0 {
        didSet { if oldValue != preferredMinimumSpacing { needsLayout = true } }
    }
    
    var preferredSectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16) {
        didSet { if oldValue != preferredSectionInset { needsLayout = true } }
    }
    
    var minimumItemWidth: CGFloat = 120 {
        didSet { if oldValue != minimumItemWidth { needsLayout = true } }
    }
    
    var maximumItemWidth: CGFloat = 180 {
        didSet { if oldValue != maximumItemWidth { needsLayout = true } }
    }
    
    // 内部布局常量
    var yearHeaderHeight: CGFloat = 80 {
        didSet { if oldValue != yearHeaderHeight { needsLayout = true } }
    }
    var monthAspectRatio: CGFloat = 1.4 {
        didSet { if oldValue != monthAspectRatio { needsLayout = true } }
    }
    
    // MARK: - 计算属性（只读）
    private(set) var calculatedItemWidth: CGFloat = 0
    private(set) var calculatedItemMargin: CGFloat = 0
    private(set) var calculatedItemsPerRow: Int = 3
    private(set) var calculatedSectionInset: UIEdgeInsets = .zero
    
    // MARK: - 内部属性
    private var needsLayout = true
    private var lastCollectionWidth: CGFloat = 0
    
    // MARK: - 初始化
    override init() {
        super.init()
        setupDefaults()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefaults()
    }
    
    private func setupDefaults() {
        scrollDirection = .vertical
        minimumInteritemSpacing = preferredMinimumSpacing
        minimumLineSpacing = preferredMinimumSpacing
    }
    
    // MARK: - 布局计算
    private func calculateLayoutIfNeeded() {
        guard let collectionView = collectionView else { return }
        
        let width = collectionView.bounds.width
        
        // 如果宽度没变且不需要重新计算，直接返回
        if !needsLayout && width == lastCollectionWidth {
            return
        }
        
        lastCollectionWidth = width
        needsLayout = false
        
        // 设置 header 大小
        headerReferenceSize = CGSize(width: width, height: yearHeaderHeight)
        
        // 从最多月数开始尝试，找到最佳列数
        var bestItemsPerRow = minimumItemsPerRow
        var bestItemWidth: CGFloat = 0
        var bestMargin: CGFloat = 0
        var bestInset: UIEdgeInsets = preferredSectionInset
        
        for itemsPerRow in (minimumItemsPerRow...maximumItemsPerRow).reversed() {
            let itemsPerRowFloat = CGFloat(itemsPerRow)
            
            // 计算可用宽度
            let availableWidth = width - preferredSectionInset.left - preferredSectionInset.right
            
            // 计算间距总和
            let totalSpacing = preferredMinimumSpacing * (itemsPerRowFloat - 1)
            
            // 计算 item 宽度
            let itemWidth = floor((availableWidth - totalSpacing) / itemsPerRowFloat)
            
            // 检查是否满足最小宽度要求，并且每行最少列数要求
            if itemWidth >= minimumItemWidth {
                // 计算实际使用的总宽度
                let actualTotalWidth = itemWidth * itemsPerRowFloat + totalSpacing
                
                // 计算实际的左右边距（让内容居中）
                let actualLeftInset = max(preferredSectionInset.left, (width - actualTotalWidth) / 2)
                let actualRightInset = max(preferredSectionInset.right, (width - actualTotalWidth) / 2)
                
                bestItemsPerRow = itemsPerRow
                bestItemWidth = itemWidth
                bestMargin = preferredMinimumSpacing
                bestInset = UIEdgeInsets(
                    top: preferredSectionInset.top,
                    left: actualLeftInset,
                    bottom: preferredSectionInset.bottom,
                    right: actualRightInset
                )
                break
            }
        }
        
        // 如果所有行数都不满足最小宽度要求，使用最少月数但允许小于最小宽度
        if bestItemWidth == 0 {
            let itemsPerRowFloat = CGFloat(minimumItemsPerRow)
            let availableWidth = width - preferredSectionInset.left - preferredSectionInset.right
            
            // 尝试使用更小的间距来满足最小宽度
            var adjustedSpacing = preferredMinimumSpacing
            var itemWidth = floor((availableWidth - adjustedSpacing * (itemsPerRowFloat - 1)) / itemsPerRowFloat)
            
            // 如果仍然小于最小宽度，减小间距直到满足最小宽度或间距为0
            while itemWidth < minimumItemWidth && adjustedSpacing > 0 {
                adjustedSpacing = max(0, adjustedSpacing - 1)
                itemWidth = floor((availableWidth - adjustedSpacing * (itemsPerRowFloat - 1)) / itemsPerRowFloat)
            }
            
            bestItemWidth = itemWidth
            bestMargin = adjustedSpacing
            
            let actualTotalWidth = bestItemWidth * itemsPerRowFloat + adjustedSpacing * (itemsPerRowFloat - 1)
            let actualLeftInset = max(preferredSectionInset.left, (width - actualTotalWidth) / 2)
            
            bestInset = UIEdgeInsets(
                top: preferredSectionInset.top,
                left: actualLeftInset,
                bottom: preferredSectionInset.bottom,
                right: max(preferredSectionInset.right, (width - actualTotalWidth) / 2)
            )
        }
        
        
        // 检查是否超过最大宽度，如果是则调整间距和边距
        if bestItemWidth > maximumItemWidth {
            let itemsPerRowFloat = CGFloat(bestItemsPerRow)
            
            // 将 item 宽度限制在最大值
            bestItemWidth = maximumItemWidth
            
            // 计算使用最大宽度后的总内容宽度
            let contentWidth = bestItemWidth * itemsPerRowFloat
            
            // 计算剩余可用空间
            let remainingSpace = width - contentWidth
            
            // 计算可以分配的总间距数（列间间距 + 左右边距）
            let totalGapsCount = itemsPerRowFloat - 1 + 2 // 列间间距数 + 左右2个边距
            
            // 将剩余空间平均分配到间距和边距
            let extraSpacePerGap = floor(remainingSpace / totalGapsCount)
            
            // 更新间距（至少保持最小间距）
            bestMargin = max(preferredMinimumSpacing, extraSpacePerGap)
            
            // 重新计算间距后的总宽度
            let totalSpacingWidth = bestMargin * (itemsPerRowFloat - 1)
            let totalContentWidth = contentWidth + totalSpacingWidth
            let remainingInsetSpace = floor(width - totalContentWidth)
            
            // 左右边距各分配剩余空间的一半
            let leftInset = max(preferredSectionInset.left, remainingInsetSpace / 2)
            let rightInset = max(preferredSectionInset.right, remainingInsetSpace / 2)
            
            bestInset = UIEdgeInsets(
                top: preferredSectionInset.top,
                left: leftInset,
                bottom: preferredSectionInset.bottom,
                right: rightInset
            )
        }
        
        // 更新计算结果
        calculatedItemWidth = bestItemWidth
        calculatedItemMargin = bestMargin
        calculatedItemsPerRow = bestItemsPerRow
        calculatedSectionInset = bestInset
        
        // 应用计算结果到布局
        minimumInteritemSpacing = bestMargin
        minimumLineSpacing = bestMargin
        sectionInset = bestInset
        itemSize = CGSize(width: bestItemWidth, height: bestItemWidth * monthAspectRatio)
    }
    
    // MARK: - 重写布局方法
    override func prepare() {
        calculateLayoutIfNeeded()
        super.prepare()
    }
    
    override func invalidateLayout() {
        needsLayout = true
        super.invalidateLayout()
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return newBounds.width != collectionView.bounds.width
    }
    
    // MARK: - 公开方法
    func forceRelayout() {
        needsLayout = true
        invalidateLayout()
    }
}
