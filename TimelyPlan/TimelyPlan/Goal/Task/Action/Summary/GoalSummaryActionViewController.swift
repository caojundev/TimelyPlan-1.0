//
//  GoalSummaryActionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/13.
//

import Foundation
import UIKit

/// 目标任务「概览」操作内容视图控制器
class GoalSummaryActionViewController: TPTableSectionsViewController {

    /// 区块上方普通间距高度
    private static let normalHeaderHeight = 5.0

    /// 目标任务操作交互器
    private let interactor: GoalTaskEditInteractor

    /// 进度概览卡片
    private let summaryCardView = GoalSummaryCardView()

    /// 专注时长数据提供者
    private lazy var focusDurationProvider = GoalFocusStatsDataProvider(task: interactor.task)

    /// 专注时长卡片
    private lazy var focusDurationCardView = FocusDurationCardView(provider: focusDurationProvider)

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let horizontalPadding: CGFloat = 20
    private let topPadding: CGFloat = 5.0

    /// 卡片之间的间距
    private let cardSpacing: CGFloat = 12.0

    init(interactor: GoalTaskEditInteractor) {
        self.interactor = interactor
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        adapter.reloadData()

        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(summaryCardView)
        contentView.addSubview(focusDurationCardView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        /// 每次展示都按最新任务刷新（进度可能在别的页签里被记录）
        reloadSummaryCard()
    }

    /// 用最新任务刷新进度概览卡片
    private func reloadSummaryCard() {
        let task = GoalSummaryTask(task: interactor.task)
        summaryCardView.configure(with: GoalSummaryCalculator.snapshot(for: task))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.frame = view.bounds

        let cardWidth = view.bounds.width - horizontalPadding * 2
        let cardSize = CGSize(width: cardWidth, height: .greatestFiniteMagnitude)

        /// 进度概览卡片
        let summaryCardHeight = summaryCardView.sizeThatFits(cardSize).height
        summaryCardView.frame = CGRect(x: horizontalPadding,
                                       y: topPadding,
                                       width: cardWidth,
                                       height: summaryCardHeight)

        /// 专注时长卡片
        focusDurationCardView.frame = CGRect(x: horizontalPadding,
                                             y: summaryCardView.frame.maxY + cardSpacing,
                                             width: cardWidth,
                                             height: focusDurationCardView.preferredHeight)

        contentView.frame = CGRect(x: 0.0,
                                   y: 0.0,
                                   width: view.bounds.width,
                                   height: focusDurationCardView.frame.maxY + topPadding)
        scrollView.contentSize = contentView.bounds.size
    }

    // MARK: - 外观

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
}

// MARK: - GoalTask 转换 GoalSummaryTask

private extension GoalSummaryTask {
    
    init(task: GoalTask) {
        let now = Date()
        self.init(initialValue: Int(task.initialValue),
                  startDate: task.startDate ?? now.startOfDay(),
                  endDate: task.endDate ?? now.dateByAddingMonths(1)?.endOfDay() ?? now,
                  currentValue: Int(task.currentValue),
                  targetValue: Int(task.targetValue))
    }
}
