//
//  TodoTaskBoardViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/15.
//

import Foundation

class TodoTaskBoardViewController: TPViewController {
    
    /// 列表视图
    private lazy var boardView: TodoTaskBoardView = {
        let view = TodoTaskBoardView()
//        view.delegate = self
        return view
    }()
    
    private var reorder: TodoTaskBoardDragInsertReorder?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(boardView)
        boardView.reloadData()
        setupBoardReorder()
    }
    
    func setupBoardReorder() {
        self.reorder = TodoTaskBoardDragInsertReorder(boardView: boardView)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        boardView.frame = view.bounds
    }
}
