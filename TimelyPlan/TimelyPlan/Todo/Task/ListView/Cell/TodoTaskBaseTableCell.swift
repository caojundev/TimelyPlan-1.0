//
//  TodoTaskBaseTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/13.
//

import Foundation
import UIKit

class TodoTaskBaseTableCell: UITableViewCell, Checkable {
    
    weak var delegate: AnyObject?

    /// 布局对象
    var layout: TodoTaskInfoLayout?
    
    var task: TodoTask? {
        return layout?.task
    }

    /// 信息视图
    var infoView: TodoTaskBaseInfoView!
    
    private var modificationDate: Date?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundView = UIView()
        self.selectedBackgroundView = UIView()
        self.multipleSelectionBackgroundView = UIView()
        self.backgroundView?.backgroundColor = .secondarySystemGroupedBackground
        self.selectedBackgroundView?.backgroundColor = .tertiarySystemGroupedBackground
        self.multipleSelectionBackgroundView?.backgroundColor = .secondarySystemGroupedBackground
        setupContentSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupContentSubviews() {
        contentView.addSubview(infoView)
    }
    
    override func layoutSubviews() {
       super.layoutSubviews()
       infoView.frame = bounds
       
       /// 更新信息视图布局
       if let layout = layout {
           layout.layoutIfNeeded()
           infoView.updateLayout(with: layout)
       }
    }
    
    func reloadDataIfNeeded(animated: Bool) {
        guard modificationDate != task?.modificationDate else {
            return
        }
        
        reloadData(animated: animated)
    }
    
    func reloadData(animated: Bool) {
        modificationDate = task?.modificationDate
        guard let layout = layout else {
            return
        }

        infoView.updateContent(with: layout, animated: animated)
        setNeedsLayout()
    }
    
    // MARK: - Completed
    func updateCompleted(animated: Bool = false) {
        if let task = task {
            infoView.setCompleted(task.isCompleted, animated: animated)
        }
    }
    
    // MARK: - Checkable
    private var _isChecked: Bool = false
    var isChecked: Bool {
        get { return _isChecked }
        set { setChecked(newValue, animated: false) }
    }
    
    func setChecked(_ checked: Bool, animated: Bool) {
        _isChecked = checked
    }
}
