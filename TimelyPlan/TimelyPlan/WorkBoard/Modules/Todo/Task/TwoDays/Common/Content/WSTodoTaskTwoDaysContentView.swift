//
//  WSTodoTaskTwoDaysContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 待办今明两天组件的内容视图。
///
/// 顶部为图标标题与任务总数，下方按今天、明天分为两列任务列表，中间以分隔线隔开。
class WSTodoTaskTwoDaysContentView: WSIconInfoTextValueContentView {

    /// 标题图标
    private let titleIcon = TPIcon(name: "calendar_day_24")

    /// 标题与标题图标背景色
    private let titleColor: UIColor = .primary

    /// 今天、明天的任务列
    private let todayColumnView: WSTodoTaskTwoDaysColumnView
    private let tomorrowColumnView: WSTodoTaskTwoDaysColumnView

    /// 列分隔线
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color(light: 0x000000, 0.08, dark: 0xFFFFFF, 0.12)
        return view
    }()

    /// 两列之间的间距
    private let columnSpacing: CGFloat = 8.0

    /// 分隔线宽度
    private let dividerWidth: CGFloat = 1.0

    init(maximumRowCount: Int) {
        self.todayColumnView = WSTodoTaskTwoDaysColumnView(maximumRowCount: maximumRowCount)
        self.tomorrowColumnView = WSTodoTaskTwoDaysColumnView(maximumRowCount: maximumRowCount)
        super.init(frame: .zero)

        addSubview(todayColumnView)
        addSubview(dividerView)
        addSubview(tomorrowColumnView)

        let selectHandler: (WSTodoTaskItem) -> Void = { [weak self] dataItem in
            self?.interactor?.performAction(with: dataItem)
        }
        let checkboxHandler: (WSTodoTaskItem) -> Void = { [weak self] dataItem in
            (self?.interactor as? WSTodoTaskContentInteractor)?.clickCheckbox(for: dataItem)
        }

        for columnView in [todayColumnView, tomorrowColumnView] {
            columnView.didSelectTaskHandler = selectHandler
            columnView.didClickCheckboxHandler = checkboxHandler
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 数据
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        guard let dataItem = dataItem as? WSTodoTaskTwoDaysDataItem else {
            updateHeader(title: resGetString("Today & Tomorrow"),
                         icon: titleIcon,
                         iconBackColor: titleColor,
                         count: 0)
            todayColumnView.update(title: resGetString("Today"), items: [])
            tomorrowColumnView.update(title: resGetString("Tomorrow"), items: [])
            return
        }

        updateHeader(title: resGetString("Today & Tomorrow"),
                     icon: titleIcon,
                     iconBackColor: titleColor,
                     count: dataItem.totalCount)
        todayColumnView.update(title: dataItem.today.title,
                               items: dataItem.today.items)
        tomorrowColumnView.update(title: dataItem.tomorrow.title,
                                  items: dataItem.tomorrow.items)
    }

    // MARK: - 布局
    override func layoutContent(in frame: CGRect) {
        guard frame.width > 0.0, frame.height > 0.0 else {
            return
        }

        let columnWidth = max((frame.width - dividerWidth - columnSpacing * 2.0) / 2.0, 0.0)
        todayColumnView.frame = CGRect(x: frame.minX,
                                       y: frame.minY,
                                       width: columnWidth,
                                       height: frame.height)
        dividerView.frame = CGRect(x: todayColumnView.right + columnSpacing,
                                   y: frame.minY + 2.0,
                                   width: dividerWidth,
                                   height: max(frame.height - 4.0, 0.0))
        tomorrowColumnView.frame = CGRect(x: dividerView.right + columnSpacing,
                                          y: frame.minY,
                                          width: columnWidth,
                                          height: frame.height)
    }
}
