//
//  GoalSummaryActionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/13.
//

import Foundation
import UIKit

/// 目标任务「概览」操作内容视图控制器
///
/// 用一张 `GoalSummaryCardView` 展示传入目标任务（`GoalTaskEditInteractor.task`）的进度概况。
/// 卡片高度按宽度算出（`sizeThatFits`），因此外层用滚动视图承载。
class GoalSummaryActionViewController: TPTableSectionsViewController {

    /// 区块上方普通间距高度
    private static let normalHeaderHeight = 5.0

    /// 目标任务操作交互器
    private let interactor: GoalTaskEditInteractor

    /// 概览卡片（只有一张）
    private let card = GoalSummaryCardView()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let horizontalPadding: CGFloat = 20
    private let topPadding: CGFloat = 5.0

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
        contentView.addSubview(card)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        /// 每次展示都按最新任务刷新（进度可能在别的页签里被记录）
        reloadCard()
    }

    /// 用最新任务刷新卡片
    private func reloadCard() {
        let task = GoalSummaryTask(task: interactor.task)
        card.configure(with: GoalSummaryCalculator.snapshot(for: task))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.frame = view.bounds

        let cardWidth = view.bounds.width - horizontalPadding * 2
        let cardHeight = card.sizeThatFits(CGSize(width: cardWidth, height: .greatestFiniteMagnitude)).height
        card.frame = CGRect(x: horizontalPadding, y: topPadding, width: cardWidth, height: cardHeight)

        contentView.frame = CGRect(x: 0.0,
                                   y: 0.0,
                                   width: view.bounds.width,
                                   height: card.frame.maxY + topPadding)
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
