//
//  MemberBannerCheckBadgeView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/17.
//

import UIKit

// MARK: - 金色勾选徽章（圆形 + 对勾）
final class MemberBannerCheckBadgeView: UIView {

    init(diameter: CGFloat) {
        super.init(frame: .zero)
        self.size = CGSize(width: diameter, height: diameter)
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let d = min(rect.width, rect.height)
        let circleRect = CGRect(x: (rect.width - d) / 2, y: (rect.height - d) / 2, width: d, height: d)

        // 金色圆底
        let colors = [MemberBannerTheme.Color.goldLight.cgColor, MemberBannerTheme.Color.goldDeep.cgColor] as CFArray
        if let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) {
            ctx.saveGState()
            ctx.addEllipse(in: circleRect)
            ctx.clip()
            ctx.drawLinearGradient(g,
                                   start: circleRect.origin,
                                   end: CGPoint(x: circleRect.maxX, y: circleRect.maxY),
                                   options: [])
            ctx.restoreGState()
        }

        // 对勾
        let w = d, h = d
        let path = UIBezierPath()
        path.move(to: CGPoint(x: w * 0.28, y: h * 0.52))
        path.addLine(to: CGPoint(x: w * 0.44, y: h * 0.68))
        path.addLine(to: CGPoint(x: w * 0.74, y: h * 0.34))
        path.lineWidth = max(1.4, d * 0.13)
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        MemberBannerTheme.Color.goldInk.setStroke()
        path.stroke()
    }
}
