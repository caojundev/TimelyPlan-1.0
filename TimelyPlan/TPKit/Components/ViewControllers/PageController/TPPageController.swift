//
//  TPPageController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/21.
//

import Foundation
import UIKit

/// 缓存策略
enum TPPageControllerCachePolicy: Int {
    case disabled = -1
    case noLimit = 0
    case low = 1
    case middle = 3
    case high = 5
}

/// 预加载策略
enum TPPageControllerPreloadPolicy: Int {
    case none = 0         ///< 不预加载
    case neighbor = 1     ///< 预加载前后各一个
    case near = 2         ///< 预加载前后各两个
}

protocol TPPageControllerDataSource: AnyObject {
    
    /// 获取视图控制器数目
    func numberOfViewControllers(in pageController: TPPageController) -> Int
    
    /// 获取索引处的视图控制器
    func pageController(_ pageController: TPPageController, viewControllerAt index: Int) -> UIViewController!
    
    /// 菜单高度
    func pageControllerMenuHeight(_ pageController: TPPageController) -> CGFloat
}

protocol TPPageControllerDelegate: AnyObject {
    
    /// 选中页面通知
    func pageController(_ pageController: TPPageController, didSelectPageAt index: Int)
}

class TPPageController: UIViewController,
                            UIScrollViewDelegate,
                            TPPageControllerDataSource,
                            TPPageControllerDelegate {
    
    weak var delegate: TPPageControllerDelegate?
    weak var dataSource: TPPageControllerDataSource?

    var cachePolicy: TPPageControllerCachePolicy = .noLimit {
        didSet {
            self.foreCache.countLimit = cachePolicy.rawValue
        }
    }
    
    var preloadPolicy: TPPageControllerPreloadPolicy = .neighbor

    ///< 是否检测滑动的进度
    var trackingProgress: Bool = true
    
    var isScrollEnabled: Bool {
        get {
            return scrollView.isScrollEnabled
        }
        
        set {
            scrollView.isScrollEnabled = newValue
        }
    }

    var bounces: Bool {
        get {
            return scrollView.bounces
        }
        
        set {
            scrollView.bounces = newValue
        }
    }
    
    var menuView: (UIView & TPPageMenuRepresentable)? {
        didSet {
            if menuView === oldValue {
                return
            }
            
            oldValue?.removeFromSuperview()
            if let menuView = menuView, !menuView.isDescendant(of: self.view) {
                self.view.addSubview(menuView)
            }
            
            self.view.setNeedsLayout()
        }
    }
    
    /// 当前选中页面索引
    var selectedPageIndex: Int {
        return validPageIndex(of: currentPageIndex)
    }
    
    /// 当前展示页索引
    private var currentPageIndex: Int = -1         // 当前页索引
    private var fromPageIndex: Int = 0             // 起始页索引
    private var toPageIndex: Int = 0               // 结束页索引

    /// 当前已经显示的视图控制器
    private var presentedViewControllersDic: [Int: UIViewController] = [:]

    /// 程序在 foreground 状态时的缓存
    private var foreCache = NSCache<NSString, UIViewController>() // 前台缓存

    /// 程序进入 background 状态时用来保存 foreCache
    private var backCache: [NSString: UIViewController] = [:] // 后台缓存

    /// 内存警告计数
    private var memoryWarningCount: Int = 0

    // 页面滚动视图
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = view.bounds
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    deinit {
        self.cancelPreviousChageCachePolicyPerform()
        self.removeNotification()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.navigationController?.navigationBar.isTranslucent = false
        self.view.addSubview(self.scrollView)
        self.addNotification()
        self.selectPage(at: 0)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = self.view.safeAreaLayoutGuide.layoutFrame
        let menuHeight = self.menuHeight
        if let menuView = menuView, menuView.isDescendant(of: self.view) {
            menuView.frame = CGRect(x: layoutFrame.minX,
                                    y: layoutFrame.minY,
                                    width: layoutFrame.width,
                                    height: menuHeight)
        }
        
        self.scrollView.frame = containerViewFrame()
        self.scrollView.contentSize = self.scrollViewContentSize()
        
        /// 布局已展示的视图控制器
        for (index, viewController) in self.presentedViewControllersDic {
            viewController.view.frame = self.pageFrame(at: index)
        }
        
        self.scrollView.contentOffset = self.pageOffset(at: self.currentPageIndex)
    }
    
    func containerViewFrame() -> CGRect {
        let layoutFrame = self.view.safeAreaLayoutGuide.layoutFrame
        let menuHeight = self.menuHeight
        let containerY = layoutFrame.minY + menuHeight
        return CGRect(x: 0.0,
                      y: containerY,
                      width: layoutFrame.width,
                      height: layoutFrame.maxY - containerY)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.memoryWarningCount += 1
        self.cancelPreviousChageCachePolicyPerform()
        self.cachePolicy = .low
        self.foreCache.removeAllObjects()
        if self.memoryWarningCount < 3 {
            self.changeCachePolicyAfterMemoryWarning()
        }
    }
    
    // MARK: - 选择
    func selectPage(at index: Int, animated: Bool = false) {
        guard self.currentPageIndex != index else {
            return
        }
        
        let moveCount = labs(self.currentPageIndex - index)
        var duration = 0.0
        if animated {
            duration = min(0.4 + CGFloat(moveCount) * 0.2, 1.8)
        }
        
        self.addViewControllerIfNeeded(at: index)
        self.currentPageIndex = index
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: [.beginFromCurrentState, .curveEaseInOut]) {
            let offset = self.pageOffset(at: index)
            self.scrollView.setContentOffset(offset, animated: false)
        } completion: { _ in
            self.preloadViewControllersIfNeeded()
        }
        
        self.menuView?.selectItem(at: index, animated: animated)
    }

    // MARK: - 视图控制器操作
    private func preloadViewControllersIfNeeded() {
        let sideLoadCount = self.preloadPolicy.rawValue
        var leftLoadIndex = self.currentPageIndex - sideLoadCount
        leftLoadIndex = validPageIndex(of: leftLoadIndex)
        
        var rightLoadIndex = self.currentPageIndex + sideLoadCount
        rightLoadIndex = validPageIndex(of: rightLoadIndex)
        

        /// 预加载 leftLoadIndex 和 rightLoadIndex 之间的 ViewController
        for i in leftLoadIndex...rightLoadIndex {
            self.addViewControllerIfNeeded(at: i)
        }
        
        /// 移除预加载之外的 ViewController
        for index in presentedViewControllersDic.keys {
            if index < leftLoadIndex || index > rightLoadIndex {
                self.removeViewControllerIfNeeded(at: index)
            }
        }
    }
    
    private func addViewControllerIfNeeded(at index: Int) {
        guard isValidIndex(index), presentedViewControllersDic[index] == nil else {
            /// 不需要添加
            return
        }
        
        ///< 从缓存获取
        var vc = self.foreCache.object(forKey: String(index) as NSString)
        if vc == nil {
            /// 缓存没有数据，从对应数据源获取
            let viewController = (self.dataSource?.pageController(self, viewControllerAt: index))!
            if self.cachePolicy != .disabled {
                self.foreCache.setObject(viewController, forKey: String(index) as NSString)
            }
            
            vc = viewController
        }
        
        let viewController = vc!
        let pageFrame = self.pageFrame(at: index)
        if viewController.view.frame != pageFrame {
            viewController.view.frame = pageFrame
        }
        
        self.presentedViewControllersDic[index] = viewController
        self.addChild(viewController)
        viewController.didMove(toParent: self)
        
        /// 最后添加视图
        self.scrollView.addSubview(viewController.view)
    }
    
    private func removeViewControllerIfNeeded(at index: Int) {
        if let vc = self.presentedViewControllersDic[index] {
            self.presentedViewControllersDic.removeValue(forKey: index)
            
            vc.view.removeFromSuperview()
            vc.willMove(toParent: nil)
            vc.removeFromParent()
            if self.cachePolicy == .disabled {
                return
            }
            
            /// 添加到缓存
            let key = String(index) as NSString
            if self.foreCache.object(forKey: key) == nil {
                self.foreCache.setObject(vc, forKey: key)
            }
        }
    }

    // MARK: - Notification
    private func addNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    private func removeNotification() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func appWillResignActive() {
        for i in 0..<pagesCount {
            let key = String(i) as NSString
            if let obj = foreCache.object(forKey: key) {
                backCache[key] = obj
            }
        }
    }

    @objc private func appWillEnterForeground() {
        for key in backCache.keys {
            if foreCache.object(forKey: key) == nil {
                if let obj = backCache[key] {
                    foreCache.setObject(obj, forKey: key)
                }
            }
        }
    
        backCache.removeAll()
    }
    
    // MARK: - Cache Policy
    private func cancelPreviousChageCachePolicyPerform() {
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(changeCachePolicyAfterMemoryWarning),
                                               object: nil)
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(changeCachePolicyToHigh),
                                               object: nil)
    }

    @objc private func changeCachePolicyAfterMemoryWarning() {
        self.perform(#selector(changeCachePolicyToMiddle), with: nil, afterDelay: 3.0, inModes: [.common])
    }

    @objc private func changeCachePolicyToMiddle() {
        self.cachePolicy = .middle
        self.perform(#selector(changeCachePolicyToHigh), with: nil, afterDelay: 3.0, inModes: [.common])
    }

    @objc private func changeCachePolicyToHigh() {
        self.cachePolicy = .high
    }

    // MARK: - Helpers
    private var pagesCount: Int {
        let count = self.dataSource?.numberOfViewControllers(in: self)
        return count ?? 0
    }
    
    private var menuHeight: CGFloat {
        let height = self.dataSource?.pageControllerMenuHeight(self)
        return height ?? 0.0
    }
    
    private func pageOffset(at index: Int) -> CGPoint {
        return CGPoint(x: CGFloat(index) * scrollView.frame.size.width, y: 0)
    }

    private func pageFrame(at index: Int) -> CGRect {
        return CGRect(x: CGFloat(index) * scrollView.frame.size.width,
                      y: 0,
                      width: scrollView.frame.size.width,
                      height: scrollView.frame.size.height)
    }

    private func isPageOnScreen(at pageIndex: Int) -> Bool {
        let pageFrame = pageFrame(at: pageIndex)
        let offsetX = scrollView.contentOffset.x
        let pageWidth = scrollView.frame.size.width
        
        /// 到 offsetX 的距离小于页面宽度
        return abs(pageFrame.minX - offsetX) < pageWidth
    }

    private func isValidIndex(_ index: Int) -> Bool {
        return index >= 0 && index < pagesCount
    }

    /// 返回一个合法的页面索引
    private func validPageIndex(of index: Int) -> Int {
        if isValidIndex(index) {
            return index
        }
        
        if index >= pagesCount {
            return pagesCount - 1
        }
        
        return max(index, 0)
    }

    private func currentPageIndex(of scrollView: UIScrollView) -> Int {
        let pageWidth = scrollView.frame.width
        let index = Int(scrollView.contentOffset.x / pageWidth + 0.5)
        return validPageIndex(of: index)
    }

    private func scrollViewContentSize() -> CGSize {
        let width = CGFloat(pagesCount) * scrollView.frame.size.width
        let height = scrollView.frame.size.height
        return CGSize(width: width, height: height)
    }
    
    /// 是否是当前呈现的视图控制器
    func isCurrentViewController(_ viewController: UIViewController) -> Bool {
        let presentedViewController = self.presentedViewControllersDic[self.currentPageIndex]
        if presentedViewController === viewController {
            return true
        }
        
        return false
    }

    
    // MARK: - TPPageControllerDataSource
    func numberOfViewControllers(in pageController: TPPageController) -> Int {
        return 0
    }
    
    func pageController(_ pageController: TPPageController, viewControllerAt index: Int) -> UIViewController! {
        return nil
    }
    
    func pageControllerMenuHeight(_ pageController: TPPageController) -> CGFloat {
        return 0.0
    }
    
    
    // MARK: - TPPageControllerDelegate
    func pageController(_ pageController: TPPageController, didSelectPageAt index: Int) {
        
    }
    
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for i in 0..<pagesCount {
            if isPageOnScreen(at: i) {
                addViewControllerIfNeeded(at: i)
            }
        }

        if trackingProgress {
            let progress = scrollView.contentOffset.x / scrollView.frame.size.width
            menuView?.updateMenu(with: progress)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPageIndex = currentPageIndex(of: scrollView)
        if currentPageIndex != self.currentPageIndex {
            self.currentPageIndex = currentPageIndex
            addViewControllerIfNeeded(at: currentPageIndex)
            preloadViewControllersIfNeeded()
            menuView?.selectItem(at: currentPageIndex, animated: true)
            delegate?.pageController(self, didSelectPageAt: currentPageIndex)
        }
    }
    
}

