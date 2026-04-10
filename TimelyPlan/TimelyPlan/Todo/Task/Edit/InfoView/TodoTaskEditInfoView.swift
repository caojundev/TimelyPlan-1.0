//
//  TodoTaskEditInfoView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/6.
//

import Foundation
import UIKit

protocol TodoTaskEditInfoViewDelegate: AnyObject {

    /// 点击检查按钮
    func todoTaskEditInfoView(_ infoView: TodoTaskEditInfoView, didClickCheckbox checkbox: TodoTaskCheckbox)
    
    /// 结束名称编辑
    func todoTaskEditInfoView(_ infoView: TodoTaskEditInfoView, didEndEditingName name: String?)
    
    /// 内容高度改变
    func todoTaskEditInfoViewContentHeightDidChange(_ infoView: TodoTaskEditInfoView)
}

class TodoTaskEditInfoView: UIView, TodoTaskEditNameViewDelegate {
    
    /// 代理对象
    weak var delegate: TodoTaskEditInfoViewDelegate?

    /// 任务名称
    var name: String? {
        didSet {
            nameView.name = name
        }
    }
    
    /// 优先级
    var priority: TodoTaskPriority {
        get {
            return nameView.priority
        }
        
        set {
            nameView.priority = newValue
        }
    }

    /// 检查类型
    var checkType: TodoTaskCheckType {
        get {
            return nameView.checkType
        }
        
        set {
            nameView.checkType = newValue
        }
    }
    
    /// 任务是否已完成
    var isCompleted: Bool {
        get {
            return nameView.isCompleted
        }
        
        set {
            nameView.setCompleted(newValue)
        }
    }
    
    /// 详细富文本信息
    var attributedDetailInfo: ASAttributedString? {
        didSet {
            detailView.attributedInfo = attributedDetailInfo
        }
    }
    
    var checkbox: TodoTaskCheckbox {
        return nameView.checkbox
    }
    
    /// 内容高度
    var contentHeight: CGFloat {
        var height = padding.verticalLength + nameTopMargin + nameHeight + detailHeight
        if !isProgressHidden {
            height += progressHeight
        }
        
        return height
    }
    
    /// 进度条是否隐藏
    var isProgressHidden: Bool {
        get {
            return progressView.isHidden
        }
        
        set {
            progressView.isHidden = newValue
            setNeedsLayout()
        }
    }
    
    /// 进度
    var progress: CGFloat {
        get {
            return progressView.progress
        }
        
        set {
            progressView.progress = newValue
        }
    }
    
    /// 名称高度
    private var nameHeight: CGFloat {
        return nameView.contentHeight
    }
    
    /// 详情高度
    private var detailHeight: CGFloat {
        return detailView.contentHeight
    }
    
    /// 进度视图
    private lazy var progressView: TPBarProgressView = {
        let view = TPBarProgressView(frame: .zero, style: .horizontal)
        view.isUserInteractionEnabled = false
        view.barForeColor = .primary
        return view
    }()
    
    /// 名称编辑
    private lazy var nameView: TodoTaskEditNameView = {
        let view = TodoTaskEditNameView()
        view.delegate = self
        return view
    }()
    
    /// 任务信息视图
    private lazy var detailView: TodoTaskEditDetailView = {
        let view = TodoTaskEditDetailView()
        return view
    }()
    
    /// 名称顶部间距
    private let nameTopMargin = 10.0
    
    /// 进度条高度
    private let progressHeight = 4.0
    
    /// 任务名称最大高度
    private let maximumNameHeight = 120.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(bottom: 10.0)
        self.addSubview(progressView)
        self.addSubview(detailView)
        self.addSubview(nameView)
        self.nameView.maximumHeight = maximumNameHeight
        self.addSeparator(position: .bottom)
        self.isProgressHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        
        /// 进度视图
        progressView.width = layoutFrame.width
        progressView.height = progressHeight
        progressView.origin = layoutFrame.origin
        
        /// 名称视图
        nameView.width = layoutFrame.width
        nameView.height = nameHeight
        nameView.left = layoutFrame.minX
        nameView.top = progressView.bottom + nameTopMargin
        
        /// 详情视图
        detailView.width = layoutFrame.width
        detailView.height = detailHeight
        detailView.left = layoutFrame.minX
        detailView.top = nameView.bottom
    }
    
    // MARK: - Public Methods
    func setProgress(_ progress: CGFloat, animated: Bool = false) {
        progressView.setProgress(progress, animated: animated)
    }
    
    func setCompleted(_ isCompleted: Bool, animated: Bool = false) {
        nameView.setCompleted(isCompleted, animated: animated)
    }
    
    // MARK: - TodoTaskEditNameViewDelegate
    func todoTaskEditNameViewDidClickCheckbox(_ nameView: TodoTaskEditNameView) {
        delegate?.todoTaskEditInfoView(self, didClickCheckbox: nameView.checkbox)
    }
    
    func todoTaskEditNameViewEditingChanged(_ nameView: TodoTaskEditNameView) {
        if nameView.contentHeight != nameView.height {
            /// 高度改变
            delegate?.todoTaskEditInfoViewContentHeightDidChange(self)
        }
    }
    
    func todoTaskEditNameViewDidEndEditing(_ nameView: TodoTaskEditNameView) {
        var newName = nameView.name
        if newName == nil || newName?.count == 0 {
            /// 恢复为编辑前的名称
            newName = name
        }
        
        if name != newName {
            name = newName
            delegate?.todoTaskEditInfoViewContentHeightDidChange(self)
        }
        
        delegate?.todoTaskEditInfoView(self, didEndEditingName: newName)
    }
    
}
