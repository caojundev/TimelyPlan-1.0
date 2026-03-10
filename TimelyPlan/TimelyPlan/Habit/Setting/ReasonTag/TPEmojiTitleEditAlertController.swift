//
//  TPEmojiTextEditAlertController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/17.
//

import Foundation
import UIKit

class TPEmojiTitleEditAlertController: TPTextFieldAlertController {
    
    var editEmoji: String?
    
    var editTitle: String?
    
    let emojiSize = CGSize.size(12)
    
    lazy var emojiView: TPEmojiEditView = {
        let view = TPEmojiEditView()
        view.emojiDidChange = { [weak self] emoji in
            self?.textField.becomeFirstResponder()
        }
        
        return view
    }()
    
    var didEndEditingEmojiTitle: ((_ emoji: Character, _ title: String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.textAlignment = .left
        self.textField.font = BOLD_BODY_FONT
        self.additionalSize = CGSize(width: .greatestFiniteMagnitude, height: 60.0)
        self.wrapperView.padding = UIEdgeInsets(left: 65.0, right: 16.0)
        self.wrapperView.addSubview(emojiView)
        self.reloadData()
        self.actionsView.itemHeight = 52.0
        self.cancelAlertAction.style.cornerRadius = .greatestFiniteMagnitude
        self.doneAlertAction.style.cornerRadius = .greatestFiniteMagnitude
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        wrapperView.layer.cornerRadius = self.additionalSize.halfHeight
        
        let emojiMargin = (wrapperView.height - emojiSize.height) / 2.0
        emojiView.size = emojiSize
        emojiView.left = emojiMargin
        emojiView.top = emojiMargin
        emojiView.layer.cornerRadius = emojiView.size.halfHeight
        emojiView.layer.backgroundColor = UIColor.systemGray4.cgColor
    }
    
    func reloadData() {
        emojiView.emoji = editEmoji?.first
        textField.text = editTitle
        updateDoneActionEnabled()
    }
    
    override func didEndEditing() {
        if let title = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), title.count > 0 {
            let emoji = emojiView.emoji ?? emojiView.placeholderEmoji
            didEndEditingEmojiTitle?(emoji, title)
        }
    }
}
