//
//  GoalSummaryActionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/13.
//

import Foundation
import UIKit

/// 演示页：纵向滚动展示多张进度卡片。
///
/// 滚动容器内容高度同样手动计算 —— 依次调用每张卡片的 `sizeThatFits` 累加。
final class GoalSummaryActionViewController: UIViewController {

    private let theme = GoalSummaryTheme.standard

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let tasks: [GoalSummaryTask]
    private let cards: [GoalSummaryCardView]

    private let horizontalPadding: CGFloat = 20
    private let topPadding: CGFloat = 20
    private let cardSpacing: CGFloat = 20

    init() {
        /// 末尾追加一项「已逾期但未完成」的测试数据
        let tasks = GoalSummaryDemoData.samples() + [GoalSummaryActionViewController.overdueTask]
        self.tasks = tasks
        self.cards = tasks.map { _ in GoalSummaryCardView() }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 测试数据：已过截止日期且未完成，用于验证「逾期」状态。
    private static var overdueTask: GoalSummaryTask {
        let day: TimeInterval = 86_400
        let now = Date()
        return GoalSummaryTask(initialValue: 0,
                            startDate: now.addingTimeInterval(-30 * day),
                            endDate: now.addingTimeInterval(-5 * day),
                            completedCount: 4,
                            totalCount: 10)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "目标任务进度"
        view.backgroundColor = theme.canvasBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "切换外观",
            style: .plain,
            target: self,
            action: #selector(toggleAppearance)
        )

        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        for (card, task) in zip(cards, tasks) {
            let snapshot = GoalSummaryCalculator.snapshot(for: task)
            card.configure(with: snapshot)
            contentView.addSubview(card)
        }
    }

    @objc private func toggleAppearance() {
        let next: UIUserInterfaceStyle = traitCollection.userInterfaceStyle == .dark ? .light : .dark
        overrideUserInterfaceStyle = next
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.frame = view.bounds

        let cardWidth = view.bounds.width - horizontalPadding * 2
        var y = topPadding

        for card in cards {
            let height = card.sizeThatFits(CGSize(width: cardWidth, height: .greatestFiniteMagnitude)).height
            card.frame = CGRect(x: horizontalPadding, y: y, width: cardWidth, height: height)
            y = card.frame.maxY + cardSpacing
        }

        contentView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: y)
        scrollView.contentSize = contentView.bounds.size
    }
}

/*
class GoalSummaryActionViewController: TPTableSectionsViewController {
    
    /// 区块上方普通间距高度
    private static let normalHeaderHeight = 5.0
    
    /// 目标任务操作交互器
    private let interactor: GoalTaskEditInteractor

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
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
}
*/
