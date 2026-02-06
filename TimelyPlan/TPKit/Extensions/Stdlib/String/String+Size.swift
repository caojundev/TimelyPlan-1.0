//
//  String+Size.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/3.
//

import Foundation

extension String {
    
    func width(with font: UIFont) -> CGFloat {
        let size = size(with: font, maxSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: font.lineHeight))
        return size.width
    }
    
    func size(with font: UIFont, maxSize: CGSize) -> CGSize {
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let boundingRect = self.boundingRect(with: maxSize,
                                             options: options,
                                             attributes: attributes,
                                             context: nil)
        return boundingRect.size
    }
    
    static func size(with str: String, font: UIFont, maxSize: CGSize) -> CGSize {
        return str.size(with: font, maxSize: maxSize)
    }
}

extension NSAttributedString {
    
    func width(with font: UIFont) -> CGFloat {
        let size = size(with: font,
                        maxSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: font.lineHeight))
        return size.width
    }
    
    func size(with maxSize: CGSize) -> CGSize {
       let boundingRect = boundingRect(with: maxSize,
                                       options: [.usesLineFragmentOrigin, .usesFontLeading],
                                       context: nil)
       return CGSize(width: ceil(boundingRect.width), height: ceil(boundingRect.height))
    }
    
    func size(with font: UIFont, maxSize: CGSize) -> CGSize {
        let mutableAttributedString = NSMutableAttributedString(attributedString: self)
        let range = NSRange(location: 0, length: mutableAttributedString.length)
        mutableAttributedString.addAttribute(.font, value: font, range: range)
        return mutableAttributedString.size(with: maxSize)
    }
}
