//
//  GoalSummaryActionViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/13.
//

import Foundation
import UIKit

/// 目标任务「概览」操作内容视图控制器
class GoalSummaryActionViewController: TPTableSectionsViewController,
                                       GoalTaskEditInteractorObserver {

    // MARK: - 布局常量

    private enum Metrics {
        /// 卡片左右间距
        static let horizontalPadding: CGFloat = 20.0
        /// 卡片顶部间距
        static let topPadding: CGFloat = 5.0
        /// 卡片之间的间距
        static let cardSpacing: CGFloat = 12.0
    }

    // MARK: - 数据

    /// 目标任务操作交互器
    private let interactor: GoalTaskEditInteractor

    /// 当前概览快照，用于判断进度是否改变
    private var summarySnapshot: GoalSummarySnapshot?

    /// 专注时长数据提供者
    private lazy var focusDurationProvider: GoalFocusStatsDataProvider = {
        let provider = GoalFocusStatsDataProvider(task: interactor.task)
        provider.onDurationChanged = { [weak self] duration in
            self?.updateFocusDuration(with: duration)
        }
        return provider
    }()

    // MARK: - 子视图

    /// 进度概览卡片
    private let summaryCardView = GoalSummaryCardView()

    /// 专注时长卡片
    private let focusDurationCardView = GoalFocusDurationCardView()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - 生命周期

    init(interactor: GoalTaskEditInteractor) {
        self.interactor = interactor
        super.init(style: .insetGrouped)

        /// 观察目标任务变化，进度改变时刷新概览卡片
        interactor.addObserver(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        interactor.removeObserver(self)
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

        focusDurationCardView.didClickHandler = { [weak self] in
            self?.clickFocusDuration()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        /// 每次展示都按最新任务刷新（进度可能在别的页签里被记录）
        reloadSummaryCard()
        focusDurationProvider.fetchDuration()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.frame = view.bounds

        let cardWidth = view.bounds.width - Metrics.horizontalPadding * 2
        let cardSize = CGSize(width: cardWidth, height: .greatestFiniteMagnitude)

        /// 进度概览卡片
        let summaryCardHeight = summaryCardView.sizeThatFits(cardSize).height
        summaryCardView.frame = CGRect(x: Metrics.horizontalPadding,
                                       y: Metrics.topPadding,
                                       width: cardWidth,
                                       height: summaryCardHeight)

        /// 专注时长卡片
        focusDurationCardView.frame = CGRect(x: Metrics.horizontalPadding,
                                             y: summaryCardView.frame.maxY + Metrics.cardSpacing,
                                             width: cardWidth,
                                             height: focusDurationCardView.preferredHeight(for: cardWidth))

        contentView.frame = CGRect(x: 0.0,
                                   y: 0.0,
                                   width: view.bounds.width,
                                   height: focusDurationCardView.frame.maxY + Metrics.topPadding)
        scrollView.contentSize = contentView.bounds.size
    }

    // MARK: - 进度概览

    /// 按最新任务刷新进度概览卡片
    private func reloadSummaryCard() {
        apply(makeSnapshot(for: interactor.task))
    }

    /// 时间进度或完成进度改变时刷新概览卡片
    private func reloadSummaryCardIfProgressChanged(for goalTask: GoalTask) {
        let snapshot = makeSnapshot(for: goalTask)

        /// 两处进度都未变化时无需刷新
        if let current = summarySnapshot,
           abs(current.timeProgress - snapshot.timeProgress) <= 0.00001,
           abs(current.taskProgress - snapshot.taskProgress) <= 0.00001 {
            return
        }

        apply(snapshot)
    }

    /// 应用快照刷新进度概览卡片
    private func apply(_ snapshot: GoalSummarySnapshot) {
        summarySnapshot = snapshot

        /// 视图尚未加载时只记录快照，展示时再统一刷新
        guard isViewLoaded else {
            return
        }

        summaryCardView.configure(with: snapshot)
        view.setNeedsLayout()
    }

    /// 生成目标任务对应的进度快照
    private func makeSnapshot(for goalTask: GoalTask) -> GoalSummarySnapshot {
        return GoalSummaryCalculator.snapshot(for: GoalSummaryTask(task: goalTask))
    }

    // MARK: - 专注时长

    /// 刷新专注时长
    private func updateFocusDuration(with duration: Int64) {
        focusDurationCardView.update(duration: Duration(duration))
        /// 时长文本宽度变化可能影响卡片布局
        view.setNeedsLayout()
    }

    // MARK: - GoalTaskEditInteractorObserver

    /// 任务改变：时间进度或完成进度改变时刷新概览卡片
    func goalTaskEditInteractor(_ interactor: GoalTaskEditInteractor,
                                didUpdateTask task: GoalTask,
                                with change: GoalTaskChange?) {
        reloadSummaryCardIfProgressChanged(for: task)
    }

    // MARK: - 事件响应

    /// 点击专注时长卡片，展示该任务的专注统计
    private func clickFocusDuration() {
        FocusPresenter.showStatistics(for: interactor.task)
    }

    // MARK: - 外观

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }

    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
}

// MARK: - 专注时长卡片视图

/// 专注时长卡片：展示目标任务的总专注时长，点击查看该任务的专注统计
private final class GoalFocusDurationCardView: TPBaseButton {

    /// 布局常量
    private enum Metrics {
        /// 卡片圆角
        static let cornerRadius: CGFloat = 12.0
        /// 内容间距
        static let contentPadding: CGFloat = 16.0
    }

    /// 信息视图
    private let infoView: TPImageInfoTextValueView = {
        let view = TPImageInfoTextValueView()
        view.imageName = "schedule_time_24"
        view.title = resGetString("Focus Duration")
        view.padding = UIEdgeInsets(value: Metrics.contentPadding)
        view.valueConfig = .valueText(nil)
        return view
    }()

    // MARK: - 初始化

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        /// 卡片样式与点击反馈
        cornerRadius = Metrics.cornerRadius
        normalBackgroundColor = .secondarySystemGroupedBackground
        selectedBackgroundColor = .secondarySystemFill
        preferredTappedScale = 1.0
        impactFeedbackStyle = .light
    }

    // MARK: - 子视图

    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(infoView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = contentView.bounds
    }

    override func contentSizeThatFits(_ size: CGSize) -> CGSize {
        return infoView.sizeThatFits(size)
    }

    // MARK: - 配置

    /// 更新专注时长
    func update(duration: Duration) {
        let text = duration.attributedTitle(symbolColor: .secondaryLabel)
        infoView.valueConfig = .valueText(text)
    }

    /// 指定宽度下的卡片高度
    func preferredHeight(for width: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        return sizeThatFits(size).height
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
