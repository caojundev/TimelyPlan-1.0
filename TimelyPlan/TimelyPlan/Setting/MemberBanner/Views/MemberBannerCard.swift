//
//  MemberBannerCard.swift
//  MemberBanner
//
//  方案二核心组件：浅色主题下的「已开通会员」紧凑金卡。
//
//  设计要点（对应设计稿）：
//  - 深色黑金卡片，落在浅色页面上形成视觉焦点
//  - 双描边（外描边 + 内细线）营造徽章/证书质感
//  - 皇冠徽标 + 金色渐变标题 + 有效期副文案
//  - 底部一行：金色对勾「权益已全部解锁」 + 右侧「查看权益 ›」
//
//  布局策略：完全 frame 手动布局，尺寸由外部给定宽度、内部按设计比例算高。
//  组件本身不关心内容来源，只认 MemberStatus。
//

import Foundation
import UIKit

protocol MemberBannerCardDelegate: AnyObject {
    /// 点击「查看权益」，由外部决定跳转逻辑（解耦）
    func memberBannerCardDidTapDetail(_ card: MemberBannerCard)
}

final class MemberBannerCard: UIView {

    // MARK: - 对外

    weak var delegate: MemberBannerCardDelegate?

    /// 依数据刷新界面
    func bind(_ status: MemberStatus) {
        crownBadge.isHidden = false
        titleLabel.text = status.cardTitle
        subtitleLabel.text = status.cardSubtitle
        unlockLabel.text = status.unlockText
        setNeedsLayout()
    }

    /// 推荐高度（供外部布局参考），宽度为外部给定
    static func preferredHeight(forWidth width: CGFloat) -> CGFloat {
        return 120.0
    }

    /// 卡片内部布局常量（静态，供 preferredHeight 与实例布局共用）
    private enum Layout {
        static let radius: CGFloat = 22      // 金卡圆角
        static let innerInset: CGFloat = 4   // 金卡内侧细描边内缩
        static let contentPadding = UIEdgeInsets(value: 16.0)
        static let crownSize = CGSize(width: 46.0, height: 46.0)
        static let titleLeftMargin: CGFloat = 12.0
        static let titleHeight: CGFloat = 25.0
        static let subtitleHeight: CGFloat = 15
        static let subtitleTopMargin = 4.0
        static let checkBadgeSize = CGSize.size(4)
    }

    // MARK: - 子视图（全部私有，外部只通过 bind 交互）

    private let backgroundGradient = CAGradientLayer()
    private let innerBorder = UIView()
    private let glowView = GoldGlowView()
    private let crownBadge = UIImageView()
    private let titleLabel = MemberBannerGradientLabel()
    private let subtitleLabel = UILabel()
    private let checkBadge = MemberBannerCheckBadgeView(diameter: 16)
    private let unlockLabel = UILabel()
    private let detailButton = TPDefaultButton()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupStyles()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - 组装

    private func setupHierarchy() {
        backgroundColor = .clear

        // 卡片本体圆角裁剪 + 深色渐变
        layer.cornerRadius = Layout.radius
        layer.masksToBounds = true
        backgroundGradient.colors = [MemberBannerTheme.Color.cardTop.cgColor,
                                     MemberBannerTheme.Color.cardMid.cgColor,
                                     MemberBannerTheme.Color.cardBottom.cgColor]
        backgroundGradient.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradient.endPoint   = CGPoint(x: 1, y: 1)
        layer.insertSublayer(backgroundGradient, at: 0)

        // 内层细描边（不裁剪，直接贴在内容之上）
        innerBorder.layer.cornerRadius = Layout.radius - Layout.innerInset
        innerBorder.layer.borderWidth = 1
        innerBorder.layer.borderColor = MemberBannerTheme.Color.cardInnerLine.cgColor
        innerBorder.isUserInteractionEnabled = false

        // 左下角金色柔光
        glowView.isUserInteractionEnabled = false
        addSubview(glowView)
        
        crownBadge.contentMode = .scaleAspectFit
        crownBadge.image = resGetImage("memberBanner_crown_46")
        addSubview(crownBadge)
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(checkBadge)
        addSubview(unlockLabel)
        addSubview(detailButton)
        addSubview(innerBorder)
        detailButton.addTarget(self, action: #selector(handleDetailTap), for: .touchUpInside)
    }

    private func setupStyles() {
        titleLabel.configure(text: "尊享会员 · 年度", font: MemberBannerTheme.Font.serif(16.5))
        titleLabel.gradientColors = [MemberBannerTheme.Color.cardTitle, MemberBannerTheme.Color.cardTitleEnd]

        subtitleLabel.font = MemberBannerTheme.Font.sans(11.5)
        subtitleLabel.textColor = MemberBannerTheme.Color.cardSubtitle
        subtitleLabel.text = "有效期至 2027.03.15 · 剩余 519 天"

        unlockLabel.font = MemberBannerTheme.Font.sans(11.5)
        unlockLabel.textColor = MemberBannerTheme.Color.cardBodyText
        unlockLabel.text = "权益已全部解锁"


        
        detailButton.title = "查看权益"
        detailButton.padding = .zero
        detailButton.imagePosition = .right
        detailButton.titleConfig.font = MemberBannerTheme.Font.sans(11.5, .medium)
        detailButton.titleConfig.textColor = MemberBannerTheme.Color.cardLinkText
        detailButton.titleConfig.textAlignment = .right
        detailButton.imageConfig.shouldRenderImageWithColor = true
        detailButton.imageConfig.color = MemberBannerTheme.Color.cardLinkText
        detailButton.imageConfig.margins = .zero
        detailButton.imageConfig.size = .size(3)
        detailButton.image = resGetImage("chevron_right_16")
    }

    // MARK: - 布局（核心：全部 frame 手算）

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundGradient.frame = bounds
        
        // 内细描边
        innerBorder.frame = CGRect(x: Layout.innerInset,
                                   y: Layout.innerInset,
                                   width: width - Layout.innerInset * 2,
                                   height: height - Layout.innerInset * 2)

        let layoutFrame = bounds.inset(by: Layout.contentPadding)
        crownBadge.frame = CGRect(x: layoutFrame.minX,
                                  y: layoutFrame.minY,
                                  width: Layout.crownSize.width,
                                  height: Layout.crownSize.height)

        let textLeft = crownBadge.right + Layout.titleLeftMargin
        let textWidth = layoutFrame.maxX - textLeft
        let textBlockHeight = Layout.titleHeight + Layout.subtitleHeight + Layout.subtitleTopMargin
        let textTop = layoutFrame.minY + (Layout.crownSize.height - textBlockHeight) / 2.0
        
        titleLabel.frame = CGRect(x: textLeft,
                                  y: textTop,
                                  width: textWidth,
                                  height: Layout.titleHeight)
        subtitleLabel.frame = CGRect(x: textLeft,
                                     y: titleLabel.bottom + Layout.subtitleTopMargin,
                                     width: textWidth,
                                     height: Layout.subtitleHeight)

        // 左下：对勾 + 解锁文案
        checkBadge.frame = CGRect(x: layoutFrame.minX,
                                  y: layoutFrame.maxY - Layout.checkBadgeSize.height,
                                  width: Layout.checkBadgeSize.width,
                                  height: Layout.checkBadgeSize.height)
        
        unlockLabel.sizeToFit()
        unlockLabel.left = checkBadge.right + 4.0
        unlockLabel.centerY = checkBadge.centerY

        detailButton.sizeToFit()
        detailButton.right = layoutFrame.maxX
        detailButton.centerY = checkBadge.centerY

        // 左下角柔光位置
        glowView.frame = CGRect(x: -60, y: height - 130, width: 190, height: 190)
    }

    // MARK: - 交互

    @objc private func handleDetailTap() {
        delegate?.memberBannerCardDidTapDetail(self)
    }
}

// MARK: - 金色柔光（径向渐变，用于卡片左下角的氛围光）
final class GoldGlowView: UIView {

    private let gradient = CAGradientLayer()

    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        isUserInteractionEnabled = false

        // 用 radial 类型模拟设计稿里的圆形柔光
        gradient.type = .radial
        gradient.colors = [
            Color(0xE8C77E, 0.22).cgColor,
            Color(0xE8C77E, 0.0).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint   = CGPoint(x: 1, y: 1)
        layer.addSublayer(gradient)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
}
