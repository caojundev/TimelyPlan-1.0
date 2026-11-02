//
//  MyDayTimelinePageViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

class MyDayTimelinePageViewController: TPViewController {

    struct Config {
        /// 添加视图按钮
        static let addViewSize = CGSize(width: 40.0, height: 40.0)
        
        /// 添加视图边界间距
        static let addViewMargins = UIEdgeInsets(top: 10.0,
                                                 left: 0.0,
                                                 bottom: 10.0,
                                                 right: 20.0)
    }
    
    /// 内容视图
    let contentView = UIView()
    
    /// 页面视图
    private(set) lazy var pageView: MyDayTimelinePageView = {
        let view = MyDayTimelinePageView(frame: .zero)
        view.delegate = self
        view.eventAddController = self.addController
        return view
    }()
    
    /// 添加视图
    private(set) lazy var addView: TPAddView = {
        let view = TPAddView()
        view.normalBackgroundColor = .primary
        view.didClickAdd = { [weak self] _ in
            self?.clickEventAdd()
        }
        
        return view
    }()
    
    /// 待办任务快速添加控制器
    private(set) lazy var quickAddManager: TodoTaskQuickAddManager = {
        let options = TodoQuickAddOptions(showMoreSetting: false,
                                          forbidContinuousAdd: true)
        let manager = TodoTaskQuickAddManager(containerViewController: self, options: options)
        return manager
    }()
    
    /// 事项添加控制器
    private(set) lazy var addController: EventAddController = {
        let controller = EventAddController()
        controller.quickAddManager = quickAddManager
        return controller
    }()
    
    /// 添加事项使用的日期
    var addEventDate: Date? {
        return pageView.visibleDate
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(contentView)
        contentView.addSubview(pageView)
        contentView.addSubview(addView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contentView.frame = view.bounds
        layoutPageView()
        layoutAddView()
    }
    
    /// 布局页面视图，子类重写以适配其它视图
    func layoutPageView() {
        pageView.frame = view.safeLayoutFrame()
    }
    
    /// 布局添加视图
    func layoutAddView() {
        let layoutFrame = view.safeLayoutFrame()
        addView.size = Config.addViewSize
        addView.bottom = layoutFrame.maxY - Config.addViewMargins.bottom
        addView.right = layoutFrame.maxX - Config.addViewMargins.right
    }
    
    // MARK: - 事件响应
    
    /// 点击添加按钮
    func clickEventAdd() {
        TPImpactFeedback.impactWithSoftStyle()
        
        let menuController = MyDayEventAddMenuController()
        menuController.didSelectMenuActionType = { [weak self] type in
            guard let self = self, let date = self.addEventDate else { return }
            self.addController.performAddMenuAction(with: type, on: date)
        }
        
        let sourceRect = addView.bounds.insetBy(dx: -5.0, dy: -5.0)
        menuController.showMenu(from: addView,
                                sourceRect: sourceRect,
                                isCovered: true)
    }
    
    /// 分页视图切换到了新日期，子类重写以响应
    func pageViewDidChangeVisibleDate(_ date: Date) {}
}

extension MyDayTimelinePageViewController: TPDayPageViewDelegate {
    
    // MARK: - TPDayPageViewDelegate
    func dayPageViewWillEndDragging(_ pageView: TPDayPageView, withTargetDate targetDate: Date) {
        pageViewDidChangeVisibleDate(targetDate)
    }
}
