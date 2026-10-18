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
/// 页数等同于组件个数，翻页时同步页内标题、副标题与页码指示器，展示当前页的组件与页码。
class WSPluginGalleryViewController: TPViewController {
    
    struct Constants {
        
        /// 内容与页面边缘的间距
        static let padding = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 20.0, right: 16.0)
        
        /// 标题与副标题的间距
        static let subtitleSpacing = 6.0
        
        /// 副标题与画廊的间距
        static let gallerySpacing = 20.0
        
        /// 画廊与页码指示器的间距。UIPageControl 在圆点上下自带留白，取值已扣除该部分
        static let indicatorSpacing = 2.0
        
        /// 页码指示器与按钮的间距
        static let indicatorMargin = 12.0
        
        /// 添加插件按钮高度
        static let buttonHeight = 50.0
    }
    
    /// 点击「添加插件」按钮，参数为当前页展示的组件
    var didClickAdd: ((WSPlugin) -> Void)?
    
    /// 页内标题
    private lazy var titleLabel: TPLabel = {
        let label = TPLabel()
        label.font = UIFont.boldSystemFont(ofSize: 22.0)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    /// 页内副标题
    private lazy var subtitleLabel: TPLabel = {
        let label = TPLabel()
        label.font = .systemFont(ofSize: 14.0)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    /// 页码指示器
    private lazy var pageIndicator: UIPageControl = {
        let pageIndicator = UIPageControl()
        /// 只保留圆点，不要 iOS 14 起自带的背景
        pageIndicator.backgroundStyle = .minimal
        pageIndicator.pageIndicatorTintColor = .tertiaryLabel
        pageIndicator.currentPageIndicatorTintColor = .label
        pageIndicator.addTarget(self,
                                action: #selector(pageControlValueChanged(_:)),
                                for: .valueChanged)
        return pageIndicator
    }()
    
    /// 添加插件按钮
    private lazy var addButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.title = resGetString("Add Plugin")
        button.titleConfig.font = BOLD_SYSTEM_FONT
        button.titleConfig.textColor = .white
        button.normalBackgroundColor = .primary
        button.selectedBackgroundColor = .primary.darkerColor
        button.cornerRadius = .greatestFiniteMagnitude
        button.addTarget(self, action: #selector(clickAddPlugin), for: .touchUpInside)
        return button
    }()
    
    /// 画廊视图
    private lazy var galleryView: WSPluginGalleryView = {
        let galleryView = WSPluginGalleryView(frame: .zero)
        galleryView.delegate = self
        galleryView.plugins = plugins
        return galleryView
    }()
    
    /// 当前页展示的组件
    private var currentPlugin: WSPlugin? {
        let page = galleryView.currentPage
        guard page >= 0, page < plugins.count else {
            return nil
        }
        
        return plugins[page]
    }
    
    let module: WSPluginModule
    
    /// 画廊展示的组件
    var plugins: [WSPlugin]
    
    init(module: WSPluginModule) {
        self.module = module
        self.plugins = module.types.map { type in
            WSPlugin(identifier: type.rawValue, type: type)
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = module.title
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
        layoutContentViews()
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(galleryView)
        view.addSubview(pageIndicator)
        view.addSubview(addButton)
        
        galleryView.reloadData()
        updatePageContent()
    }
    
    private func layoutContentViews() {
        var layoutFrame = contentFrame
        /// 为「添加插件」按钮留出底部安全区（Home 指示条）
        layoutFrame.size.height -= view.safeAreaInsets.bottom
        layoutFrame = layoutFrame.inset(by: Constants.padding)
        
        /// 标题与副标题在内容宽度内居中对齐，高度由文本自适应
        titleLabel.width = layoutFrame.width
        subtitleLabel.width = layoutFrame.width
        titleLabel.sizeToFit()
        subtitleLabel.sizeToFit()
        
        titleLabel.top = layoutFrame.minY
        titleLabel.alignHorizontalCenter()
        
        subtitleLabel.top = titleLabel.bottom + Constants.subtitleSpacing
        subtitleLabel.alignHorizontalCenter()
        
        /// 按钮固定在底部
        addButton.width = layoutFrame.width
        addButton.height = Constants.buttonHeight
        addButton.left = layoutFrame.minX
        addButton.bottom = layoutFrame.maxY
        
        /// 指示器在按钮上方，高度取系统控件的固有高度
        pageIndicator.width = layoutFrame.width
        pageIndicator.height = pageIndicator.intrinsicContentSize.height
        pageIndicator.left = layoutFrame.minX
        pageIndicator.bottom = addButton.top - Constants.indicatorMargin
        
        /// 画廊占据副标题与指示器之间的剩余空间，条目尺寸会随画廊高度自适应
        let galleryTop = subtitleLabel.bottom + Constants.gallerySpacing
        let galleryBottom = pageIndicator.top - Constants.indicatorSpacing
        galleryView.frame = CGRect(x: 0.0,
                                   y: galleryTop,
                                   width: view.bounds.width,
                                   height: max(0.0, galleryBottom - galleryTop))
    }
    
    // MARK: - 当前页
    /// 同步当前页的标题、副标题、页码指示器与导航栏标题
    private func updatePageContent() {
        let page = galleryView.currentPage
        pageIndicator.numberOfPages = plugins.count
        pageIndicator.currentPage = page
        
        guard let plugin = currentPlugin else {
            titleLabel.text = nil
            subtitleLabel.text = nil
            self.title = nil
            self.view.setNeedsLayout()
            return
        }
        
        titleLabel.text = plugin.type.title
        subtitleLabel.text = plugin.type.subtitle
        self.view.setNeedsLayout()
    }
    
    // MARK: - Event Response
    /// 点击 / 拖动页码指示器，翻到对应页
    @objc private func pageControlValueChanged(_ pageControl: UIPageControl) {
        galleryView.scrollToPage(pageControl.currentPage, animated: true)
    }
    
    @objc private func clickAddPlugin() {
        addCurrentPlugin()
    }
    
    /// 添加当前页展示的插件
    private func addCurrentPlugin() {
        guard let plugin = currentPlugin else {
            return
        }
        
        didClickAdd?(plugin)
    }
}

// MARK: - WSPluginGalleryViewDelegate
extension WSPluginGalleryViewController: WSPluginGalleryViewDelegate {
    
    func galleryView(_ galleryView: WSPluginGalleryView, didScrollToPage page: Int) {
        updatePageContent()
    }
    
    func galleryView(_ galleryView: WSPluginGalleryView, didSelectItemAt indexPath: IndexPath) {
        /// 点击组件同样视为添加当前页展示的组件
        addCurrentPlugin()
    }
}
