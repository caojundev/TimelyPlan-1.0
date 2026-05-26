//
//  TPTableKeyboardAdjuster.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/24.
//

import Foundation
import UIKit

class TPTableKeyboardAdjuster {
    
    /// 绑定的滚动视图
    private let tableView: UITableView
    
    var keyboardIntersectionBottom: CGFloat = 0.0 {
        didSet {
            tableView.keyboardIntersectionBottom = keyboardIntersectionBottom
            
            var contentInset = initalContentInset
            if contentInset.bottom < keyboardIntersectionBottom {
                contentInset.bottom = keyboardIntersectionBottom
            }
            
            tableView.contentInset = contentInset
        }
    }
    
    var isEnabled: Bool = false {
        didSet {
            if isEnabled {
                addKeyboardNotification()
            } else {
                removeKeyboardNotification()
            }
        }
    }
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    deinit {
        removeKeyboardNotification()
    }
    
    // MARK: - 键盘
    func addKeyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    var initalContentInset: UIEdgeInsets = .zero

    @objc func keyboardWillShow(_ notification: Notification) {
        initalContentInset = tableView.contentInset
        
        guard let tableSuperview = tableView.superview,
              let userInfo = notification.userInfo,
                let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let offsetY: CGFloat = 0.0
        /// 根据y间距调整键盘 frame 信息
        var keyboardFrame = frameValue.cgRectValue
        keyboardFrame.origin.y -= offsetY
        keyboardFrame.size.height += offsetY
        
        let convertedKeyboardFrame = tableSuperview.convert(keyboardFrame, fromViewOrWindow: nil)
        let intersectionFrame = convertedKeyboardFrame.intersection(tableView.frame)
        keyboardIntersectionBottom = intersectionFrame.height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        keyboardIntersectionBottom = 0.0
    }

}

