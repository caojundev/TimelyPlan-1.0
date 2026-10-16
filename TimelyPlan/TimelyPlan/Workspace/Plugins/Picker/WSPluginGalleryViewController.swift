//
//  WSPluginGalleryViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/16.
//

import Foundation
import UIKit

/// 组件画廊。
///
/// 由 `WSPluginGalleryView` 承载：水平翻页浏览组件，一页一个组件，并在页内居中显示。
/// 页数等同于组件个数，翻页时同步标题，展示当前页的组件与页码。
class WSPluginGalleryViewController: TPViewController {
    
    /// 画廊展示的组件。默认使用测试数据，一页展示一个组件
    var elements: [WSPluginElement] = WSPluginElement.mockElements() {
        didSet {
            guard isViewLoaded else {
                return
            }
            
            galleryView.elements = elements
            galleryView.reloadData()
            updateTitle(forPage: galleryView.currentPage)
        }
    }
    
    /// 画廊视图
    private lazy var galleryView: WSPluginGalleryView = {
        let galleryView = WSPluginGalleryView(frame: .zero)
        galleryView.delegate = self
        galleryView.elements = elements
        return galleryView
    }()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSubviews()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        galleryView.frame = contentFrame
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        view.addSubview(galleryView)
        galleryView.reloadData()
        updateTitle(forPage: galleryView.currentPage)
    }
    
    // MARK: - 标题
    /// 标题展示当前页的组件与页码。组件个数即页数，一页一个组件
    private func updateTitle(forPage page: Int) {
        guard !elements.isEmpty else {
            self.title = nil
            return
        }
        
        let index = min(max(page, 0), elements.count - 1)
        self.title = "\(elements[index].type.displayName)  \(index + 1)/\(elements.count)"
    }
}

// MARK: - WSPluginGalleryViewDelegate
extension WSPluginGalleryViewController: WSPluginGalleryViewDelegate {
    
    func galleryView(_ galleryView: WSPluginGalleryView, didScrollToPage page: Int) {
        updateTitle(forPage: page)
    }
    
    func galleryView(_ galleryView: WSPluginGalleryView, didSelectItemAt indexPath: IndexPath) {
        /// TODO: 待工作台的组件添加能力就绪后，在此把选中的组件添加到工作台并关闭画廊
    }
}
