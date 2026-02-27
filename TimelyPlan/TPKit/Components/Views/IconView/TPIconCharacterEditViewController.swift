//
//  TPIconCharacterEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/26.
//

import Foundation
import UIKit

class TPIconCharacterEditViewController: TPViewController {
    
    /// 点击确认回调
    var didEndEditing: ((String) -> Void)?
    
    /// 字符文本（取其首字符）
    var text: String? {
        get {
            guard let emoji = characterView.emoji else {
                return String(characterView.placeholderEmoji)
            }
            
            return String(emoji)
        }
        
        set {
            characterView.emoji = newValue?.first
        }
    }
    
    lazy var characterView: TPEmojiEditView = {
        let view = TPEmojiEditView()
        return view
    }()
    
    lazy var confirmButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.title = resGetString("Confirm")
        button.titleConfig.font = BOLD_SYSTEM_FONT
        button.titleConfig.textColor = .white
        button.normalBackgroundColor = Color(0x3855EE)
        button.cornerRadius = .greatestFiniteMagnitude
        button.addTarget(self, action: #selector(didClickConfirm), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Edit Emoji")
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        view.addSubview(characterView)
        view.addSubview(confirmButton)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let layoutFrame = view.safeLayoutFrame()
        
        characterView.size = CGSize(value: 80.0)
        characterView.backgroundColor = Color(0x888888, 0.1)
        characterView.top = 40.0
        characterView.alignHorizontalCenter()
        
        let confirmButtonWidth = layoutFrame.width - 40.0
        confirmButton.width = min(confirmButtonWidth, 420.0)
        confirmButton.height = 56.0
        confirmButton.marginBottom(30.0, ofView: characterView)
        confirmButton.alignHorizontalCenter()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override func handleFirstAppearance() {
        characterView.beginEditing()
    }
    
    @objc func didClickConfirm() {
        TPImpactFeedback.impactWithSoftStyle()
        if let text = text {
            didEndEditing?(text)
        }
        
        dismiss(animated: true)
    }
    
    func beginEditing() {
        characterView.beginEditing()
    }
    
    func endEditing() {
        characterView.endEditing()
    }
}
