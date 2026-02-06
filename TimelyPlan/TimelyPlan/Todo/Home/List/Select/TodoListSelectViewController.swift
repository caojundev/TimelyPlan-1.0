//
//  TodoListSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/15.
//

import Foundation

class TodoListSelectViewController: TPViewController {
    
    /// 选中列表回调
    var didSelectList: ((TodoListRepresentable?) -> Void)?

    /// 选中列表
    var list: TodoListRepresentable? {
        didSet {
            selectView.list = list
        }
    }
    
    private lazy var selectView: TodoListSelectView = {
        let view = TodoListSelectView()
        view.list = self.list
        view.didSelectList = { [weak self] list in
            self?.didSelectList?(list)
        }
        
        return view
    }()
    
    init(list: TodoListRepresentable?) {
        self.list = list
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.view.addSubview(self.selectView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.selectView.frame = self.view.bounds
    }
}
