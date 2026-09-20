//
//  CountdownDetailViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/20.
//

import Foundation
import UIKit

class CountdownDetailViewController: UIViewController {
    
    // MARK: - 数据
    var eventTitle: String = "生日"
    var targetDate: Date = Calendar.current.date(byAdding: .day, value: 100, to: Date())!
    
    // MARK: - 视图
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let daysLabel = UILabel()
    private let daysUnitLabel = UILabel()
    private let timeStackView = UIStackView()
    private var timer: Timer?
    
    // 数字卡片
    private let hourCard = NumberCardView()
    private let minuteCard = NumberCardView()
    private let secondCard = NumberCardView()
    
    private lazy var backgroundView: CountdownBackgroundView = {
        return CountdownBackgroundView(frame: view.bounds)
    }()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startCountdown()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateEntry()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView.frame = view.bounds
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - UI布局（手动计算frame）
    private func setupUI() {
        
        view.addSubview(backgroundView)
        
        let width = view.bounds.width
        let height = view.bounds.height
        
        // 标题
        titleLabel.text = eventTitle
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 0, y: height * 0.12, width: width, height: 34)
        titleLabel.alpha = 0
        view.addSubview(titleLabel)
        
        // 日期
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        dateLabel.text = formatter.string(from: targetDate)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        dateLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        dateLabel.textAlignment = .center
        dateLabel.frame = CGRect(x: 0, y: titleLabel.frame.maxY + 12, width: width, height: 20)
        dateLabel.alpha = 0
        view.addSubview(dateLabel)
        
        // 天数大字
        daysLabel.text = "00"
        daysLabel.textColor = .white
        daysLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 120, weight: .black)
        daysLabel.textAlignment = .center
        let daysWidth: CGFloat = 280
        daysLabel.frame = CGRect(x: (width - daysWidth) / 2, y: height * 0.28, width: daysWidth, height: 130)
        daysLabel.alpha = 0
        view.addSubview(daysLabel)
        
        // 添加光晕
        daysLabel.layer.shadowColor = UIColor(red: 0.6, green: 0.4, blue: 1, alpha: 1).cgColor
        daysLabel.layer.shadowRadius = 20
        daysLabel.layer.shadowOpacity = 0.5
        daysLabel.layer.shadowOffset = .zero
        
        daysUnitLabel.text = "天"
        daysUnitLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        daysUnitLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        daysUnitLabel.frame = CGRect(x: daysLabel.frame.maxX + 8, y: daysLabel.frame.maxY - 35, width: 30, height: 28)
        daysUnitLabel.alpha = 0
        view.addSubview(daysUnitLabel)
        
        // 时分秒卡片
        let cardWidth: CGFloat = 80
        let cardHeight: CGFloat = 90
        let cardSpacing: CGFloat = 20
        let totalWidth = cardWidth * 3 + cardSpacing * 2
        let cardY = daysLabel.frame.maxY + 40
        
        hourCard.frame = CGRect(x: (width - totalWidth) / 2, y: cardY, width: cardWidth, height: cardHeight)
        minuteCard.frame = CGRect(x: hourCard.frame.maxX + cardSpacing, y: cardY, width: cardWidth, height: cardHeight)
        secondCard.frame = CGRect(x: minuteCard.frame.maxX + cardSpacing, y: cardY, width: cardWidth, height: cardHeight)
        
        hourCard.unitText = "时"
        minuteCard.unitText = "分"
        secondCard.unitText = "秒"
        
        [hourCard, minuteCard, secondCard].forEach {
            $0.alpha = 0
            view.addSubview($0)
        }
        
        // 底部提示
        let tipLabel = UILabel()
        tipLabel.text = "距离目标还有"
        tipLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        tipLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        tipLabel.textAlignment = .center
        tipLabel.frame = CGRect(x: 0, y: hourCard.frame.maxY + 30, width: width, height: 18)
        tipLabel.alpha = 0
        view.addSubview(tipLabel)
    }
    
    // MARK: - 倒计时逻辑
    private func startCountdown() {
        updateCountdown()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCountdown()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func updateCountdown() {
        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: now, to: targetDate)
        
        let days = max(0, components.day ?? 0)
        let hours = max(0, components.hour ?? 0)
        let minutes = max(0, components.minute ?? 0)
        let seconds = max(0, components.second ?? 0)
        
        // 天数更新带动画
        if daysLabel.text != String(format: "%02d", days) {
            animateNumberFlip(label: daysLabel, value: String(format: "%02d", days))
        }
        
        hourCard.setValue(hours)
        minuteCard.setValue(minutes)
        secondCard.setValue(seconds)
        
        // 光晕呼吸动画
        animateGlowPulse()
    }
    
    // MARK: - 数字翻转动画
    private func animateNumberFlip(label: UILabel, value: String) {
        UIView.transition(with: label, duration: 0.3, options: .transitionFlipFromBottom) {
            label.text = value
        }
    }
    
    // MARK: - 光晕呼吸
    private func animateGlowPulse() {
        let pulse = CABasicAnimation(keyPath: "shadowOpacity")
        pulse.fromValue = 0.4
        pulse.toValue = 0.7
        pulse.duration = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        daysLabel.layer.add(pulse, forKey: "pulse")
    }
    
    // MARK: - 入场动画
    private func animateEntry() {
        let elements = [titleLabel, dateLabel, daysLabel, daysUnitLabel, hourCard, minuteCard, secondCard]
        let delays: [Double] = [0.0, 0.1, 0.2, 0.25, 0.35, 0.4, 0.45]
        
        for (index, view) in elements.enumerated() {
            UIView.animate(withDuration: 0.6, delay: delays[index], usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                view.alpha = 1
                view.transform = .identity
            }
        }
        
        // 初始位移
        [titleLabel, dateLabel, daysLabel, daysUnitLabel].forEach {
            $0.transform = CGAffineTransform(translationX: 0, y: -20)
        }
        [hourCard, minuteCard, secondCard].forEach {
            $0.transform = CGAffineTransform(translationX: 0, y: 20)
        }
    }
}

// MARK: - 数字卡片组件
class NumberCardView: UIView {
    
    struct Config {
        /// 数字高度
        static let numberHeight: CGFloat = 42
        /// 单位高度
        static let unitHeight: CGFloat = 16
        /// 数字与单位间距
        static let spacing: CGFloat = 4
        /// 圆角
        static let cornerRadius: CGFloat = 16
    }
    
    private let blurView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.alpha = 0.3
        blurView.isUserInteractionEnabled = false
        return blurView
    }()
    
    private let numberLabel = UILabel()
    private let unitLabel = UILabel()
    
    var unitText: String = "" {
        didSet { unitLabel.text = unitText }
    }
    
    private var currentValue: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 子视图布局（卡片尺寸在创建后才确定，需在布局阶段计算）
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurView.frame = bounds
        
        let contentHeight = Config.numberHeight + Config.spacing + Config.unitHeight
        let top = max(0.0, (bounds.height - contentHeight) / 2.0)
        numberLabel.frame = CGRect(x: 0.0,
                                   y: top,
                                   width: bounds.width,
                                   height: Config.numberHeight)
        unitLabel.frame = CGRect(x: 0.0,
                                 y: numberLabel.frame.maxY + Config.spacing,
                                 width: bounds.width,
                                 height: Config.unitHeight)
    }
    
    private func setupCard() {
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        layer.cornerRadius = Config.cornerRadius
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        clipsToBounds = true
        
        /// 毛玻璃效果
        insertSubview(blurView, at: 0)
        
        numberLabel.text = String(format: "%02d", currentValue)
        numberLabel.textColor = .white
        numberLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 36, weight: .bold)
        numberLabel.textAlignment = .center
        addSubview(numberLabel)
        
        unitLabel.text = unitText
        unitLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        unitLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        unitLabel.textAlignment = .center
        addSubview(unitLabel)
    }
    
    func setValue(_ value: Int) {
        guard value != currentValue else {
            return
        }
        
        currentValue = value
        /// 数字翻转动画
        UIView.transition(with: numberLabel, duration: 0.25, options: .transitionFlipFromTop) {
            self.numberLabel.text = String(format: "%02d", value)
        }
    }
}
