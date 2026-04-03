//
//  TodoTaskQuickAddEditView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/12/21.
//

import Foundation
import QuartzCore
import UIKit

class TodoTaskQuickAddEditView: UIScrollView,
                                 TPTextWrapperViewDelegate {
    
    /// 名称
    var name: String? {
        get {
            return nameView.text
        }
        
        set {
            nameView.text = newValue ?? ""
            self.setNeedsLayout()
        }
    }
    
    /// 备注
    var note: String? {
        get {
            return noteView.text
        }
        
        set {
            noteView.text = newValue ?? ""
            self.setNeedsLayout()
        }
    }
    
    /// 名称改变回调
    var nameDidChange: ((String?) -> Void)?
    
    /// 备注改变回调
    var noteDidChange: ((String?) -> Void)?
    
    /// 是否可以编辑备注
    var isNoteEditEnabled: Bool = false {
        didSet {
            if noteView.isFirstResponder && !isNoteEditEnabled {
                let _ = nameView.becomeFirstResponder()
            }
            
            setNeedsLayout()
        }
    }
    
    /// 内容尺寸改变回调
    var contentSizeDidChange: (() -> Void)?
    
    /// 名称文本视图
    lazy var nameView: TPTextWrapperView = {
        let view = TPTextWrapperView(frame: .zero)
        view.delegate = self
        view.padding = UIEdgeInsets(horizontal: 10.0, vertical: 5.0)
        view.isNewlineEnabled = false
        view.placeholder = resGetString("Add a Task")
        view.font = UIFont.preferredFont(forTextStyle: .title3).withBold()
        view.textView.returnKeyType = .next
        return view
    }()
    
    /// 备注文本视图
    lazy var noteView: TPTextWrapperView = {
        let view = TPTextWrapperView(frame: .zero)
        view.delegate = self
        view.padding = UIEdgeInsets(horizontal: 10.0, vertical: 5.0)
        view.isNewlineEnabled = true
        view.placeholder = resGetString("Note")
        view.font = BOLD_SMALL_SYSTEM_FONT
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        addSubview(nameView)
        addSubview(noteView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameView.width = width
        nameView.height = nameView.contentSize.height
        
        noteView.isHidden = !isNoteEditEnabled
        noteView.width = width
        noteView.height = noteView.contentSize.height
        noteView.top = nameView.bottom
        
        /// 设置内容尺寸
        let contentHeight = isNoteEditEnabled ? noteView.bottom : nameView.bottom
        self.contentSize = CGSize(width: width, height: contentHeight)
    }
    
    // MARK: - Editing
    /// 开始名称编辑
    func beginNameEditing() {
        let _ = nameView.becomeFirstResponder()
    }
    
    /// 开始备注编辑
    func beginNoteEditing() {
        let _ = noteView.becomeFirstResponder()
        let visibleRect = self.convert(noteView.bounds, fromViewOrWindow: noteView)
        self.scrollRectToVisible(visibleRect, animated: true)
    }
    
    // MARK: - TPTextWrapperViewDelegate
    func textWrapperViewDidChange(_ textWrapperView: TPTextWrapperView) {
        if textWrapperView.contentSize.height != textWrapperView.height {
            setNeedsLayout()
            layoutIfNeeded()
            contentSizeDidChange?() /// 通知内容尺寸改变
        }
        
        if textWrapperView == nameView {
            nameDidChange?(textWrapperView.text)
        } else if textWrapperView == noteView {
            noteDidChange?(textWrapperView.text)
        }
    }
    
    func textWrapperViewDidChangeSelection(_ wrapperView: TPTextWrapperView) {
        let textView = wrapperView.textView
        DispatchQueue.main.async {
            guard let textRange = textView.selectedTextRange else {
                return
            }
        
            let cursorRect = textView.caretRect(for: textRange.start)
            let visibleRect = self.convert(cursorRect, fromViewOrWindow: textView)
            self.scrollRectToVisible(visibleRect, animated: false)
        }
    }
    
    func textWrapperViewDidEndEditing(_ wrapperView: TPTextWrapperView) {
        
    }
    
    func textWrapperViewDidEnterReturn(_ wrapperView: TPTextWrapperView) {
        
    }
}
