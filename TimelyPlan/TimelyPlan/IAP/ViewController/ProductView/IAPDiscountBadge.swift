//
//  IAPDiscountBadge.swift
//  TimelyPlan
//
//  渐变折扣标签
//
//  Created by caojun on 2026/8/19.
//

import Foundation
import UIKit

final class IAPDiscountBadge: UIView {
    private let gradient = CAGradientLayer()
    private let label = UILabel()

    var text: String? {
        didSet { label.text = text; isHidden = text == nil }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradient.colors = [
            UIColor(red: 0.22, green: 0.58, blue: 0.96, alpha: 1).cgColor,
            UIColor(red: 0.22, green: 0.83, blue: 0.46, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint   = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradient)

        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        addSubview(label)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
        gradient.cornerRadius = bounds.height / 2
        label.frame = bounds
        layer.cornerRadius = bounds.height / 2
        clipsToBounds = true
    }

    /// 根据文字计算合适尺寸
    var fittingSize: CGSize {
        let t = text ?? ""
        let font = label.font ?? .systemFont(ofSize: 12, weight: .bold)
        let w = (t as NSString).size(withAttributes: [.font: font]).width
        return CGSize(width: w + 16, height: 24)
    }
}
