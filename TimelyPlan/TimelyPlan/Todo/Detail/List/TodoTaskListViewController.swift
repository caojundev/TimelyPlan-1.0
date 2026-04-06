//
//  TodoTaskListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/2.
//

import Foundation
import UIKit

class TodoTaskListViewController: UIViewController, TodoDetailContent {
    
    /// 更多按钮
    private lazy var moreBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(customView: self.moreButton)
    }()
    
    private lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = UIEdgeInsets(horizontal: 5.0)
        button.image = resGetImage("ellipsis_24")
        button.imageConfig.color = resGetColor(.title)
        button.addTarget(self, action: #selector(clickMore(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 添加视图按钮
    private let addViewSize = CGSize(width: 50.0, height: 50.0)
    
    /// 添加视图边界间距
    private let addViewMargins = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 10.0, right: 20.0)
    
    /// 添加视图
    private var addView: TPAddView?
    
    /// 任务快速添加控制器
    lazy var quickAddManager: TodoTaskQuickAddManager = {
        return TodoTaskQuickAddManager(containerViewController: self)
    }()
    
    let interactor: TodoListInteractor
    
    init(interactor: TodoListInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAddView()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeAreaFrame()
        if let addView = addView {
            addView.size = addViewSize
            addView.bottom = layoutFrame.maxY - addViewMargins.bottom
            addView.right = layoutFrame.maxX - addViewMargins.right
        }
    }
    
    // MARK: - Setup
    func setupAddView() {
        let configuration = self.interactor.configuration
        if configuration.canAddTask() {
            let addView = TPAddView()
            addView.normalBackgroundColor = configuration.addButtonBackColor()
            addView.didClickAdd = { [weak self] _ in
                self?.clickAdd()
            }
           
            self.addView = addView
            self.view.addSubview(addView)
        }
    }
    
    // MARK: - Event Response
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
//        itemsViewController.endEditing(animated: true)
        guard let menuItems = self.interactor.listOptionMenuItems(), menuItems.count > 0 else {
            return
        }
        
        let menuController = TPLevelMenuViewController(menuItems: menuItems)
        let sourceRect = CGRect(x: moreButton.bounds.maxX,
                                y: moreButton.bounds.maxY,
                                size: .zero)
        menuController.show(from: moreButton, sourceRect: sourceRect, isCovered: false)
    }
    
    /// 点击添加
    private func clickAdd() {
        TPImpactFeedback.impactWithLightStyle()
        
        let task = self.interactor.configuration.quickAddTask()
        quickAddManager.show(with: task)
    }
    
    // MARK: - TodoDetailContent
    var navigationTitle: TextRepresentable? {
        return self.interactor.title()
    }
    
    var navigationSubtitle: TextRepresentable? {
        return nil
    }
    
    var navigationLeftBarButtonItems: [UIBarButtonItem]? {
        return nil
    }
    
    var navigationRightBarButtonItems: [UIBarButtonItem]? {
        return [moreBarButtonItem]
    }
}
