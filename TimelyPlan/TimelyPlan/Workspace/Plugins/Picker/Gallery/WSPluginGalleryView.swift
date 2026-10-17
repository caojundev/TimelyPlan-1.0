//
//  WSPluginGalleryView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/16.
//

import Foundation
import UIKit

protocol WSPluginGalleryViewDelegate: AnyObject {
    
    /// 页面翻动，停在第 page 页（从 0 开始）
    func galleryView(_ galleryView: WSPluginGalleryView, didScrollToPage page: Int)
    
    /// 点击第 indexPath 个条目
    func galleryView(_ galleryView: WSPluginGalleryView, didSelectItemAt indexPath: IndexPath)
}

extension WSPluginGalleryViewDelegate {
    
    func galleryView(_ galleryView: WSPluginGalleryView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

/// 组件画廊视图
class WSPluginGalleryView: UIView,
                           TPCollectionViewAdapterDataSource,
                           TPCollectionViewAdapterDelegate {
    
    /// 代理对象
    weak var delegate: WSPluginGalleryViewDelegate?
    
    /// 画廊条目
    var elements: [WSPluginElement]?
    
    /// 占位视图提供者
    var placeholderProvider: TPPlaceholderProviding? {
        didSet {
            updatePlaceholderView()
        }
    }
    
    /// 滚动视图
    var scrollView: UIScrollView {
        return collectionView
    }
    
    /// 当前页码（从 0 开始）
    var currentPage: Int {
        return collectionViewLayout.currentPage
    }
    
    /// 页数
    var pageCount: Int {
        return collectionViewLayout.pageCount
    }
    
    /// 适配器
    private let adapter = TPCollectionViewAdapter()
    
    /// 布局对象
    private let collectionViewLayout = WSPluginGalleryFlowLayout()
    
    /// 尺寸规则。复用仪表盘的小 / 中 / 大尺寸计算，保证两个页面里同一组件尺寸观感一致
    private lazy var galleryLayout = WSDashboardLayout()
    
    /// 上一次通知的页码，用于避免重复通知
    private var notifiedPage: Int = 0
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.isPrefetchingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        /// 页宽与集合视图宽度一致，开启整页翻动
        collectionView.isPagingEnabled = true
        collectionView.shouldShowPlaceholder = { [weak self] in
            return self?.shouldShowPlaceholder() ?? false
        }
        
        return collectionView
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemGroupedBackground
        self.setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        adapter.dataSource = self
        adapter.delegate = self
        adapter.collectionView = collectionView
        collectionViewLayout.itemSizeProvider = { [weak self] indexPath in
            return self?.itemSize(at: indexPath) ?? .zero
        }
        addSubview(collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    // MARK: - Public Methods
    /// 是否显示占位视图
    func shouldShowPlaceholder() -> Bool {
        guard adapter.objects.count > 0 else {
            return true
        }
        
        return false
    }
    
    /// 更新占位视图
    func updatePlaceholderView() {
        collectionView.placeholderView = placeholderProvider?.placeholderView()
    }
    
    /// 重新加载数据
    func reloadData() {
        updatePlaceholderView()
        adapter.reloadData()
        /// 数据变化后页数可能减少、内容偏移被约束到有效页，立即布局一次以保证页码同步
        collectionView.layoutIfNeeded()
        notifyPageDidChangeIfNeeded()
    }
    
    func reloadDataIfNeeded() {
        if adapter.needsReload {
            reloadData()
        }
    }
    
    /// 更新列表
    func performUpdate(animated: Bool = false) {
        updatePlaceholderView()
        adapter.performUpdate()
    }
    
    /// 滚动到指定页
    func scrollToPage(_ page: Int, animated: Bool) {
        collectionViewLayout.scrollToPage(page, animated: animated)
        notifyPageDidChangeIfNeeded()
    }
    
    // MARK: - Elements
    /// 索引位置对应的组件
    private func element(at indexPath: IndexPath) -> WSPluginElement? {
        guard let elements = elements, indexPath.item < elements.count else {
            return nil
        }
        
        return elements[indexPath.item]
    }
    
    /// 索引位置条目的尺寸
    ///
    /// 尺寸基准边长取页面宽高中的较小值：横向布局时页面很宽但很矮，
    /// 若只按宽度推导尺寸，大号组件会超出页面而被裁掉。
    private func itemSize(at indexPath: IndexPath) -> CGSize {
        guard let element = element(at: indexPath) else {
            return .zero
        }
        
        let baseLength = layoutBaseLength()
        galleryLayout.updateLayoutIfNeeded(containerSize: CGSize(width: baseLength, height: baseLength))
        return galleryLayout.itemSize(for: element)
    }
    
    /// 尺寸计算的基准边长
    private func layoutBaseLength() -> CGFloat {
        let pageSize = adapter.collectionViewSize()
        let usableHeight = pageSize.height - collectionView.adjustedContentInset.verticalLength
        
        return max(0.0, min(pageSize.width, usableHeight))
    }
    
    // MARK: - 页码
    /// 页码变化时通知代理
    private func notifyPageDidChangeIfNeeded() {
        let page = currentPage
        guard page != notifiedPage else {
            return
        }
        
        notifiedPage = page
        delegate?.galleryView(self, didScrollToPage: page)
    }
    
    // MARK: - TPCollectionViewAdapterDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return [String(describing: type(of: self)) as NSString]
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return elements
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        delegate?.galleryView(self, didSelectItemAt: indexPath)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        /// 单元格类型由组件注册的提供者决定
        guard let element = element(at: indexPath) else {
            return WSPluginCell.self
        }
        
        return WSPluginRegistry.shared.provider(for: element.type)?.cellClass ?? WSPluginCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? WSPluginCell,
              let element = element(at: indexPath),
              let provider = WSPluginRegistry.shared.provider(for: element.type) else {
            return
        }
        
        /// 画廊里不显示长按菜单
        cell.isContextMenuEnabled = false
        cell.configure(element: element, provider: provider)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize(at: indexPath)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, lineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, interitemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        notifyPageDidChangeIfNeeded()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            notifyPageDidChangeIfNeeded()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        notifyPageDidChangeIfNeeded()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        notifyPageDidChangeIfNeeded()
    }
}
