//
//  TodoTaskPageBaseCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/14.
//

import Foundation
import UIKit

class TodoTaskPageBaseCell: UICollectionViewCell, Checkable {
    
    weak var delegate: AnyObject?

    /// 任务布局对象
    var layout: TodoTaskInfoLayout?
    
    /// 任务
    var task: TodoTask? {
        return layout?.task
    }

    /// 信息视图
    var infoView: TodoTaskBaseInfoView!
    
    /// 圆角半径
    var cornerRadius: CGFloat = 12.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundView = UIView()
        self.backgroundView?.clipsToBounds = true
        self.backgroundView?.backgroundColor = .secondarySystemGroupedBackground
        
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.clipsToBounds = true
        self.selectedBackgroundView?.backgroundColor = .tertiarySystemGroupedBackground
        
        self.setupContentSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   override func layoutSubviews() {
       super.layoutSubviews()
       infoView.frame = bounds
       backgroundView?.layer.cornerRadius = cornerRadius
       selectedBackgroundView?.layer.cornerRadius = cornerRadius
       self.tp_setBorderShadow(color: Color(0x222222, 0.2),
                               offset: .zero,
                               radius: 4.0,
                               roundCorners: .allCorners,
                               cornerRadius: cornerRadius)
   }

    func setupContentSubviews() {
        contentView.addSubview(infoView)
    }
    
    func reloadData(animated: Bool) {
        guard let layout = layout else {
            return
        }

        infoView.updateContent(with: layout, animated: animated)
        setNeedsLayout()
    }
    
    // MARK: - Completed
    func updateCompleted(animated: Bool = false) {
        guard let task = task else {
            return
        }
        
        infoView.setCompleted(task.isCompleted, animated: animated)
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
