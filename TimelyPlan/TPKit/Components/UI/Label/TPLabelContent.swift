//
//  TPLabelContent.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/10.
//

import Foundation

protocol TextRepresentable {
    
    /// 判断文本是否相同
    func isSame(as other: TextRepresentable?) -> Bool
}

extension String: TextRepresentable {
    
    func isSame(as other: TextRepresentable?) -> Bool {
        return self == other as? String
    }
}

extension ASAttributedString: TextRepresentable {
    
    func isSame(as other: TextRepresentable?) -> Bool {
        return self == other as? ASAttributedString
    }
}

extension UILabel {
    
    func update(with text: TextRepresentable?) {
        if let attributedText = text as? ASAttributedString {
            self.attributed.text = attributedText
        } else if let text = text as? String {
            self.text = text
        }
        
        self.text = nil
    }
}


class TPLabelContent: Equatable {
    
    /// 文本
    var text: String? {
        return value as? String
    }
    
    /// 富文本
    var attributedText: ASAttributedString? {
        return value as? ASAttributedString
    }
    
    private(set) var value: TextRepresentable?
    
    convenience init(text: TextRepresentable?) {
        self.init()
        self.value = text
    }
    
    static func withText(_ text: TextRepresentable?) -> TPLabelContent {
        return TPLabelContent(text: text)
    }

    // MARK: - Equatable
    static func == (lhs: TPLabelContent, rhs: TPLabelContent) -> Bool {
        return lhs.text == rhs.text && lhs.attributedText == rhs.attributedText
    }
}
