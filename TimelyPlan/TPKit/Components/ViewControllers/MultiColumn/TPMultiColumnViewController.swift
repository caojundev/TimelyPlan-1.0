//
//  TPMultiColumnViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/11.
//

import Foundation
import UIKit

class TPMultiColumnViewController: UIViewController,
                                    UIGestureRecognizerDelegate,
                                    TPColumnContainerViewDelegate {
    
    enum DetailDisplayStyle {
        case fullscreen /// 全屏显示
        case oneColumn  /// 有一列边栏
    }
    
    /// 列边栏视图控制器
    var columnViewControllers: [UIViewController] = []

    /// 详细视图控制器
    var detailViewController: UIViewController?
    
    /// 首选详细视图显示样式
    var preferredDetailDisplayStyle: DetailDisplayStyle = .oneColumn
    
    /// 详细视图实际显示样式，根据具体情况计算
    private var detailDisplayStyle: DetailDisplayStyle = .fullscreen
    
    /// 分割线颜色
    var separatorColor: UIColor = .separator {
        didSet {
            updateColumnAndDetailSeparatorColor()
        }
    }
   
    /// 边缘阴影颜色
    var edgeShadowColor: UIColor = Color(0x000000, 0.1) {
        didSet {
            if edgeShadowColor != oldValue {
                updateColumnAndDetailViewShadow() /// 更新阴影
            }
        }
    }
    
    /// 非活动边栏在最左端隐藏的宽度
    private var inactiveColumnHiddenWidth: CGFloat = 160.0
    
    /// 变成第一活动状态的触发距离
    private var firstActiveTriggerDistance: CGFloat = 80.0
    
    /// 第一个活动边栏索引
    private(set) var firstActiveColumnIndex: Int = 0 {
        didSet {
            guard firstActiveColumnIndex != oldValue else {
                return
            }
            
            /// 更新状态
            self.updateColumnStatus()
            self.firstActiveColumnIndexDidChange(fromIndex: oldValue, toIndex: firstActiveColumnIndex)
        }
    }
    
    /// 实际侧边栏宽度
    private var columnWidth: CGFloat = 320.0
    
    /// 详细视图宽度
    private var detailWidth: CGFloat = 320.0
    
    /// 内容视图
    private var contentView: UIView = UIView()
    
    private var columnContainerViews: [TPColumnContainerView] = []
    
    private var detailContainerView = TPColumnContainerView()
    
    /// 平滑手势
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        recognizer.delegate = self
        recognizer.maximumNumberOfTouches = 1
        return recognizer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupColumnAndDetailViewControllers()
        
        self.contentView.isMultipleTouchEnabled = false
        self.contentView.isExclusiveTouch = true
        self.contentView.clipsToBounds = true
        self.contentView.addGestureRecognizer(self.panGestureRecognizer)
        self.view.addSubview(self.contentView)
        self.addColumnAndDetailViewControllers()
        self.updateColumnAndDetailViewShadow()
        
        var beginColumnIndex = self.beginColumnIndex()
        self.validateColumnIndex(&beginColumnIndex)
        self.firstActiveColumnIndex = beginColumnIndex
        self.relayoutColumnsAndDetail()
        self.updateColumnStatus()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.contentView.frame = self.view.bounds
        self.detailDisplayStyle = self.fitDetailDisplayStyle
        self.columnWidth = self.fitColumnWidth
        self.detailWidth = self.fitDetailWidth
        
        if self.isDetailFirstActiveColumn && self.detailDisplayStyle == .oneColumn {
            self.firstActiveColumnIndex = self.lastColumnIndex
        }
        
        self.relayoutColumnsAndDetail()
    }

    // MARK: - 布局
    var fitColumnWidth: CGFloat {
        var columnWidth: CGFloat = 320.0
        if UIDevice.current.isPhone || UITraitCollection.isCompactMode() {
            columnWidth = self.view.bounds.size.shortSideLength
        }
        
        return columnWidth
    }

    var fitDetailWidth: CGFloat {
        var fitWidth = self.view.bounds.width
        if self.detailDisplayStyle == .oneColumn {
            fitWidth -= self.columnWidth
        }
        
        return fitWidth
    }

    
    var fitDetailDisplayStyle: DetailDisplayStyle {
        if UIDevice.current.isPhone {
            return .fullscreen
        }
    
        /// 非iPhone
        var style = self.preferredDetailDisplayStyle
        if style == .oneColumn {
            if UITraitCollection.isCompactMode() {
                style = .fullscreen
            }
        }
        
        return style
    }
    
    /// 是否显示分割线
    var shouldShowSeparator: Bool {
        if UIDevice.current.isPhone {
            return false
        }
        
        let contentSize = self.view.bounds.size
        if self.columnWidth == contentSize.shortSideLength {
            return false
        }
        
        return true
    }

    private func containerRect(at index: Int) -> CGRect {
        var rect: CGRect
        if index >= self.columnsCount {
            rect = self.detailContainerRect()
        } else {
            rect = self.columnContainerRect(at: index)
        }
        
        return rect;
    }

    private func columnContainerRect(at index: Int) -> CGRect {
        var x: CGFloat
        if index < self.firstActiveColumnIndex {
            x = -self.inactiveColumnHiddenWidth
        } else {
            x = CGFloat(index - self.firstActiveColumnIndex) * self.columnWidth
        }
        
        return CGRect(x: x, y: 0.0, width: self.columnWidth, height: self.view.height)
    }

    /// 详细容器frame信息
    private func detailContainerRect() -> CGRect {
        let x = CGFloat(self.columnsCount - self.firstActiveColumnIndex) * self.columnWidth
        return CGRect(x: x, y: 0.0, width: self.detailWidth, height: self.view.height)
    }

    
    private func relayoutColumnsAndDetail() {
        if self.columnsCount == 0 {
            return
        }
        
        let shouldShowSeparator = self.shouldShowSeparator
        for i in 0...self.columnsCount {
            guard let containerView = self.containerView(at: i) else {
                continue
            }
            
            containerView.layer.shadowOpacity = 0.0
            containerView.separatorColor = self.separatorColor
            containerView.frame = self.containerRect(at: i)
            if shouldShowSeparator {
                containerView.addSeparator()
                if i <= self.firstActiveColumnIndex {
                    containerView.separatorAlpha = 0.0
                } else {
                    containerView.separatorAlpha = 1.0
                }
            } else {
                containerView.removeSeparator()
            }
        }
    }

    // MARK: - 视图控制器初始化
    private func addColumnAndDetailViewControllers() {
        for columnVC in self.columnViewControllers {
            columnVC.multiColumnViewController = self
            self.addSubViewController(columnVC)
            let containerView = TPColumnContainerView()
            containerView.delegate = self
            containerView.viewController = columnVC
            columnContainerViews.append(containerView)
            self.contentView.addSubview(containerView)
        }
        
        self.contentView.addSubview(self.detailContainerView)
        if let detailViewController = detailViewController {
            detailViewController.multiColumnViewController = self
            self.addSubViewController(detailViewController)
            self.detailContainerView.delegate = self
            self.detailContainerView.viewController = detailViewController
        }
    }
    
    /// 设置视图控制器活动状态
    private func updateColumnStatus() {
        for i in 0...self.columnsCount {
            var status: TPMultiColumnStatus = .hidden
            if i == self.firstActiveColumnIndex {
                status = .primary
            } else if i > self.firstActiveColumnIndex {
                status = .secondary
            }
            
            let vc = self.viewController(at: i)
            vc?.multiColumnStatus = status
        }
    }
    
    
    // MARK: - 样式更新
    private func updateColumnAndDetailViewShadow() {
        for i in 0...self.columnsCount {
            let view = containerView(at: i)
            view?.clipsToBounds = false
            view?.layer.shadowOpacity = 0.0
            view?.layer.setLayerShadow(color: edgeShadowColor,
                                       offset: CGSize(width: -1.0, height: 0.0),
                                       radius: 4.0)
        }
    }
    
    private func updateColumnAndDetailSeparatorColor() {
        for i in 0...self.columnsCount {
            let view = containerView(at: i)
            view?.separatorColor = self.separatorColor
        }
    }
    
    // MARK: - 子类重写方法
    func setupColumnAndDetailViewControllers() {
        /// 子类重写
    }
    
    func beginColumnIndex() -> Int {
        return 0
    }

    func firstActiveColumnIndexDidChange(fromIndex: Int, toIndex: Int) {
        
    }

    func multiColumnPanGestureRecognizerBegan() {
        if UIMenuController.shared.isMenuVisible {
            UIMenuController.shared.hideMenu()
        }
    }

    func multiColumnPanGestureRecognizerEnded() {
        
    }
    
    // MARK: - 手势
    
    private var edgeMoveFactor: CGFloat = 0.1
    
    /// 当前活动索引
    private var currentActiveIndex: Int = 0
    
    private func panStateBegan(with translation: CGPoint) {
        self.multiColumnPanGestureRecognizerBegan()
        self.setColumnAndDetailUserInteractionEnabled(false) /// 视图禁止交互
        self.currentActiveIndex = self.firstActiveColumnIndex
    }

    /// 向左（相对于初始位置）
    private func panLeft(with translation: CGPoint) {
        let dx = translation.x
        currentActiveIndex = self.firstActiveColumnIndex + (Int)(abs(dx) / self.columnWidth)
        if self.detailDisplayStyle == .oneColumn && currentActiveIndex >= self.detailIndex {
            currentActiveIndex = self.lastColumnIndex
        } else if currentActiveIndex > self.detailIndex {
            currentActiveIndex = self.detailIndex
        }
        
        var bMoveWithFactor = false
        if currentActiveIndex == self.detailIndex ||
            (currentActiveIndex == self.lastColumnIndex && self.detailDisplayStyle == .oneColumn) {
            /// 内容页非全屏显示，并且此时活动列为最后一列，此时最后一列和detail一起移动
            bMoveWithFactor = true
        }
        
        /// 当前活动边栏进入dismissing状态，计算边界消失偏移量
        var view = containerView(at: currentActiveIndex)
        var rect = containerRect(at: currentActiveIndex)
        let leftMargin = rect.origin.x + dx
        if bMoveWithFactor {
            var x = leftMargin
            if x < 0 {
                x *= edgeMoveFactor;
                
                /// 控制详细视图右侧的最大偏移
                x = max(-self.firstActiveTriggerDistance / 2.0, x)
            }
            
            rect.origin.x = x
        } else {
            rect.origin.x = leftMargin * (self.inactiveColumnHiddenWidth / self.columnWidth)
        }
        
        view?.frame = rect
        var columnRight = rect.maxX /// 最后边栏最右端
         
        /// 计算进度
        if currentActiveIndex < self.detailIndex {
            var progress = abs(leftMargin) / (self.columnWidth * 0.8)
            progress = min(1.0, max(0.0, progress))
            let nextIndex = currentActiveIndex + 1
            self.becomeActive(for: nextIndex, with: progress)
            self.resignActive(for: currentActiveIndex, with: 1.0 - progress)
        }

        /// 其它边栏一起移动
        let nextIndex = currentActiveIndex + 1
        if nextIndex <= self.detailIndex {
            for i in nextIndex..<self.detailIndex {
                let view = containerView(at: i)
                var rect = containerRect(at: i)
                rect.origin.x += dx
                view?.frame = rect
                columnRight = rect.maxX
                
                ///< 阴影配置
                var shadowOpacity: CGFloat = 0.0
                if i == currentActiveIndex + 1 {
                    shadowOpacity = shadowOpacityForView(view)
                }
                
                view?.layer.shadowOpacity = Float(shadowOpacity)
                if let separatorView = view?.separatorView {
                    separatorView.alpha = 1.0 - shadowOpacity
                }
            }
        }
        
        if currentActiveIndex != self.detailIndex {
            /// 当前活动非详细页
            let bDetailMoveTogether = bMoveWithFactor
            view = self.detailContainerView
            rect = self.detailContainerRect()
            if bDetailMoveTogether {
                rect.origin.x = columnRight
            } else {
                rect.origin.x += dx
            }
            
            view?.frame = rect
            var shadowOpacity: CGFloat = 0.0
            if !bMoveWithFactor, currentActiveIndex + 1 == self.detailIndex {
                shadowOpacity = shadowOpacityForView(view)
            }
            
            view?.layer.shadowOpacity = Float(shadowOpacity)
            if let separatorView = view?.separatorView {
                separatorView.alpha = 1.0 - shadowOpacity
            }
        }
    }
    
    private func panRight(with translation: CGPoint) {
        let dx = translation.x
        self.currentActiveIndex = self.firstActiveColumnIndex - (Int)(abs(dx) / self.columnWidth)
        if self.currentActiveIndex < 0 {
            self.currentActiveIndex = 0
        }
        
        let previousIndex = self.currentActiveIndex - 1
        if previousIndex >= 0 {
            /// 此时该视图从inactive -> active
            let view = containerView(at: previousIndex)
            let rect = containerRect(at: previousIndex)
            var newRect = rect
            let moveDistance = dx - self.columnWidth * CGFloat(self.firstActiveColumnIndex - self.currentActiveIndex)
            newRect.origin.x = rect.origin.x + (self.inactiveColumnHiddenWidth / self.columnWidth) * moveDistance
            view?.frame = newRect
            
            /// 计算进度
            var progress = moveDistance / (self.columnWidth * 0.8)
            progress = min(1.0, max(0.0, progress))
            self.becomeActive(for: previousIndex, with: progress)
            self.resignActive(for: currentActiveIndex, with: 1.0 - progress)
        }
        
        ///< 其它边栏一起移动
        var moveFactor: CGFloat = 1.0 ///< 移动因子
        if currentActiveIndex == 0 {
            moveFactor = 0.1 ///< 当所有边栏都在右端时，缩小移动因子
        }
 
        if currentActiveIndex <= columnsCount {
            for i in currentActiveIndex...columnsCount {
                let view = containerView(at: i)
                let rect = containerRect(at: i) ///< 初始状态时Rect
                var newRect = rect
                var leftMargin = (dx - self.columnWidth * CGFloat(self.firstActiveColumnIndex)) * moveFactor
                if moveFactor < 1.0 {
                    /// 所有边栏都在右侧，控制左侧最大偏移
                    leftMargin = min(self.firstActiveTriggerDistance / 2.0, leftMargin)
                }
     
                newRect.origin.x = leftMargin + CGFloat(i) * self.columnWidth
                view?.frame = newRect;
                
                ///< 阴影配置
                var shadowOpacity = 0.0
                if i == currentActiveIndex {
                    shadowOpacity = shadowOpacityForView(view)
                }
                
                view?.layer.shadowOpacity = Float(shadowOpacity)
                if let separatorView = view?.separatorView {
                    separatorView.alpha = 1.0 - shadowOpacity
                }
            }
        }
    }
    
    private func panStateEnded(with translation: CGPoint) {
        var resultIndex = currentActiveIndex
        var resignActiveIndex: Int
        var usingSpring = false ///< 是否使用弹簧动画
        if translation.x < 0 {
            ///< 下一个
            let nextIndex = currentActiveIndex + 1
            resignActiveIndex = currentActiveIndex
            if nextIndex <= self.columnsCount {
                let nextView = containerView(at: nextIndex)
                let nextFrame = nextView?.frame ?? .zero
                if self.columnWidth - nextFrame.minX > self.firstActiveTriggerDistance {
                    resultIndex = nextIndex
                    usingSpring = true
                } else {
                    resignActiveIndex = nextIndex
                }
            }
        } else {
            var previousIndex = currentActiveIndex - 1
            previousIndex = max(0, previousIndex)
            resignActiveIndex = previousIndex

            let view = containerView(at: currentActiveIndex)
            let leftMargin = view?.frame.minX ?? 0.0
            if leftMargin > self.firstActiveTriggerDistance {
                resultIndex = previousIndex
                resignActiveIndex = currentActiveIndex;
            } else {
                usingSpring = true
            }
        }
        
        self.firstActiveColumnIndex = resultIndex
        self.becomeActive(for: resultIndex, with: 1.0)
        if resignActiveIndex != resultIndex {
            self.resignActive(for: resignActiveIndex, with: 0.0)
        }
        
        ///< 根据新的firstActiveColumnIndex 布局
        let dampingRatio = usingSpring ? 0.85 : 1.0
    
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       usingSpringWithDamping: dampingRatio,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseInOut,
                       animations: {
            self.relayoutColumnsAndDetail()
        }, completion: nil)
        
        self.setColumnAndDetailUserInteractionEnabled(true) /// 响应交互
        self.multiColumnPanGestureRecognizerEnded()
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.contentView)
        switch recognizer.state {
        case .began:
            self.panStateBegan(with: translation)
        case .changed:
            if translation.x < 0 {
                self.panLeft(with: translation)
            } else {
                self.panRight(with: translation)
            }
        default:
            self.panStateEnded(with: translation)
        }
    }

    func becomeActive(for column: Int, with progress: CGFloat) {
        let viewController = viewController(at: column)
        viewController?.becomeFirstActive(with: progress)
    }
    
    func resignActive(for column: Int, with progress: CGFloat) {
        let viewController = viewController(at: column)
        viewController?.resignFirstActive(with: progress)
    }
    
    func shadowOpacityForView(_ view: UIView?) -> CGFloat {
        guard let view = view else {
            return 0.0
        }
        
        var opacity = (self.columnWidth - view.frame.origin.x) / self.firstActiveTriggerDistance
        opacity = max(0.0, min(opacity, 1.0))
        return opacity
    }

    func setColumnAndDetailUserInteractionEnabled(_ isEnabled: Bool) {
        for columnContainerView in columnContainerViews {
            columnContainerView.isUserInteractionEnabled = isEnabled
        }
        
        self.detailContainerView.isUserInteractionEnabled = isEnabled
    }
    
    // MARK: - TraitCollection
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let previousStyle = self.detailDisplayStyle
        self.detailDisplayStyle = self.fitDetailDisplayStyle
        let previousSizeClass = previousTraitCollection?.horizontalSizeClass
        let currentSizeClass = self.traitCollection.horizontalSizeClass
        
        if (previousSizeClass == .compact || currentSizeClass == .regular) {
            /// compact -> regular
            if self.isDetailFirstActiveColumn,
                self.detailDisplayStyle == .oneColumn {
                self.firstActiveColumnIndex = self.lastColumnIndex
            }
        } else if (previousSizeClass == .regular || currentSizeClass == .compact) {
            /// regular -> compact
            if self.columnViewControllers.count > 1,
               self.firstActiveColumnIndex == self.lastColumnIndex,
               self.detailDisplayStyle == .fullscreen,
                previousStyle == .oneColumn {
                self.firstActiveColumnIndex = self.detailIndex
            }
        }
    }
    
    // MARK: - TPColumnContainerViewDelegate
    func columnContainerViewDidClickMask(_ containerView: TPColumnContainerView) {
        for i in 0...columnsCount {
            let vc = viewController(at: i)
            vc?.didClickMask(for: containerView)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    /// 边界手势触发宽度
    private let edgeGestureSilenceWidth = 50.0
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        if location.x < edgeGestureSilenceWidth {
            return false
        }
        
        if self.isFullScreen,
            UITraitCollection.isRegularMode(),
           self.detailContainerView.frame.minX == 0.0 {
            return false
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard UIResponder.currentFirstResponder() == nil else {
            return false
        }
        
        var shouldReceive = true
        var aView = touch.view
        while aView != nil {
            /// 触摸点在控件上
            if aView is UIControl || aView is UITextView {
                shouldReceive = false
                break
            }
            
            if let cell = aView as? UITableViewCell {
                shouldReceive = shouldReceiveTouch(touch, on: cell)
                break;
            }
           
            aView = aView?.superview
        }

        return shouldReceive
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    private func shouldReceiveTouch(_ touch: UITouch, on cell: UITableViewCell) -> Bool {
        let point = touch.location(in: cell)
        let triggerEdgeWidth = 30.0
        if point.x < triggerEdgeWidth || point.x > cell.frame.maxX - triggerEdgeWidth {
            return true
        }
        
        return false
    }
    
    // MARK: - 全屏操作
    var isFullScreen: Bool {
        return self.fitDetailDisplayStyle == .fullscreen
    }

    func enterFullScreen() {
        self.preferredDetailDisplayStyle = .fullscreen
        self.detailDisplayStyle = self.fitDetailDisplayStyle
        self.detailWidth = self.fitDetailWidth
        self.firstActiveColumnIndex = 0
        self.showDetailView()
    }

    func exitFullScreen() {
        self.preferredDetailDisplayStyle = .oneColumn
        self.detailDisplayStyle = self.fitDetailDisplayStyle
        self.detailWidth = self.fitDetailWidth
        self.firstActiveColumnIndex = 0
        self.showColumn(at: self.lastColumnIndex, forceLayoutDetail: true)
    }

    // MARK: - 显示 / 隐藏视图
    
    func showFirstColumn() {
        showColumn(at: 0)
    }

    func showLastColumn() {
        showColumn(at: self.lastColumnIndex)
    }

    func showDetailView() {
        showColumn(at: self.columnsCount)
    }

    func showColumn(at index: Int, forceLayoutDetail: Bool = false) {
        var index = index
        self.validateColumnIndex(&index)
        var usingSpring = false
        if index - self.firstActiveColumnIndex > 0 {
            ///< 向左收起
            usingSpring = true
        }
        
        self.firstActiveColumnIndex = index
        let dampingRatio = usingSpring ? 0.8 : 1.0
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: dampingRatio,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseInOut,
                       animations: {
            self.relayoutColumnsAndDetail()
            if forceLayoutDetail {
                self.detailView?.layoutIfNeeded()
            }
        }, completion: nil)
    }
    
    // MARK: - 用户交互
    func enableUserInteraction() {
        self.setUserInteractionEnabled(true, except: nil)
    }

    func disableUserInteraction(except viewController: UIViewController?) {
        self.setUserInteractionEnabled(false, except: viewController)
    }

    func setUserInteractionEnabled(_ isEnabled: Bool, except viewController: UIViewController? = nil) {
        var containerViews = self.columnContainerViews
        containerViews.append(self.detailContainerView)
        for containerView in containerViews {
            
            var excludedVC = viewController
            if !(viewController is UINavigationController), let navController = viewController?.navigationController {
                excludedVC = navController
            }
            
            var isUserInteractionEnabled = isEnabled
            if excludedVC == containerView.viewController {
                isUserInteractionEnabled = !isEnabled
            }
            
            if isUserInteractionEnabled {
                containerView.enableUserInteraction()
            } else {
                containerView.disableUserInteraction()
            }
        }
    }

    // MARK: - 点击前进 / 后退
    func didClickBackward(viewController: UIViewController) {
        guard let index = self.indexOfViewController(viewController) else {
            return
        }
        
        /// 显示前一列
        let columnIndex = index - 1
        if columnIndex >= 0 {
            self.showColumn(at: columnIndex)
        }
    }

    func didClickForward(viewController: UIViewController) {
        if let index = self.indexOfViewController(viewController) {
            /// 显示当前列
            self.showColumn(at: index)
        }
    }

    // MARK: - 切换新的边栏 / 详细视图控制器
    func replaceColumn(at index: Int, with viewController: UIViewController) {
        let oldViewController = self.columnViewControllers[index]
        if oldViewController == viewController {
            return;
        }
        
        self.removeSubViewController(oldViewController)
        self.addSubViewController(viewController)
        let containerView = containerView(at: index)
        containerView?.viewController = viewController
        
        self.columnViewControllers.replaceElement(at: index, with: viewController)
        self.updateColumnStatus()
    }
    
    func replaceDetail(with viewController: UIViewController?) {
        guard self.detailViewController != viewController else {
            return
        }
        
        if let oldDetailViewController = self.detailViewController {
            self.removeSubViewController(oldDetailViewController)
        }
        
        
        if let viewController = viewController {
            self.addSubViewController(viewController)
            self.detailContainerView.viewController = viewController
        }
        
        self.detailViewController = viewController
        self.updateColumnStatus()
    }

    // MARK: - Helpers
    var columnsCount: Int {
        return columnViewControllers.count
    }
    
    var lastColumnIndex: Int {
        return columnsCount - 1
    }

    var detailIndex: Int {
        return columnsCount
    }
    
    func isDetailIndex(_ index: Int) -> Bool {
        return index >= columnsCount
    }
    
    var isDetailFirstActiveColumn: Bool {
        return firstActiveColumnIndex >= columnsCount
    }
    
    var detailView: UIView? {
        return detailViewController?.view
    }
    
    private func validateColumnIndex(_ index: inout Int) {
        /// 计算实际目标索引
        if isDetailIndex(index) && self.detailDisplayStyle == .oneColumn {
            index = self.lastColumnIndex
        }
        
        if self.firstActiveColumnIndex == index {
            return
        }
        
        if index > self.columnsCount {
            index = self.columnsCount
        }
    }

    /// 根据index返回对应的视图，当index为columnsCount时返回detailView，
    private func containerView(at index: Int) -> TPColumnContainerView? {
        let idx = index < 0 ? 0 : index
        var view: TPColumnContainerView?
        if idx >= self.columnsCount {
            view = self.detailContainerView
        } else if idx < columnContainerViews.count {
            view = columnContainerViews[idx]
        }
        
        return view
    }

    private func indexOfViewController(_ vc: UIViewController) -> Int? {
        var viewControler = vc
        if !(vc is UINavigationController), let navController = vc.navigationController {
            viewControler = navController
        }
        
        var index: Int?
        if viewControler == self.detailViewController {
            index = self.columnsCount
        } else {
            index = columnViewControllers.indexOf(viewControler)
        }
        
        return index
    }
    
    private func viewController(at index: Int) -> TPMultiColumnProtocol? {
        var vc: UIViewController?
        if index < self.columnsCount {
            vc = self.columnViewControllers[index];
        } else {
            vc = self.detailViewController
        }

        if let navigationController = vc as? UINavigationController {
            vc = navigationController.topViewController
        }
        
        return vc as? TPMultiColumnProtocol
    }

    
    private func addSubViewController(_ viewController: UIViewController) {
        viewController.multiColumnViewController = self
        self.addChild(viewController)
        viewController.didMove(toParent: self)
    }

    private func removeSubViewController(_ viewController: UIViewController) {
        viewController.multiColumnViewController = nil
        viewController.view.removeFromSuperview()
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
    }

}
