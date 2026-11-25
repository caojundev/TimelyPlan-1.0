//
//  WSMyDayEventsContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/3.
//

import Foundation
import UIKit

// MARK: - 内容交互器基类

/// 我的一天组件内容交互器的公共基类。
///
/// 统一负责数据仓库的创建与事项变化监听；
/// 默认点击组件时打开当天的时间线。
class WSMyDayEventsContentInteractor: WSPluginContentInteractor, MyDayEventChangeDelegate {
    
    /// 我的一天数据仓库。仅仪表盘取数时创建，画廊只渲染预览数据
    private(set) var repository: MyDayRepository?
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        
        /// 画廊不访问数据仓库：`MyDayRepository` 初始化会连带创建各数据源观察者与系统日历，
        /// 在画廊里纯属浪费，且会阻塞主线程
        guard context == .dashboard else {
            return
        }
        
        let repository = MyDayRepository()
        self.repository = repository
        /// 观察者由数据仓库弱引用持有，无需手动移除
        repository.addUpdaterDelegate(self)
    }
    
    // MARK: - MyDayEventChangeDelegate
    /// 只有与今天有交集的事项变化才影响展示内容
    func myDayEventsDidChange(in ranges: [DateInterval]) {
        let todayRange = DateInterval.rangeOfDay(Date())
        guard ranges.contains(where: { $0.intersects(todayRange) }) else {
            return
        }
        
        pluginDataDidChange()
    }
    
    // MARK: - 主操作
    /// 点击组件：打开当天的时间线
    override func performPrimaryAction() {
        openTimeline()
    }
    
    // MARK: - 弹出
    /// 弹出当天的时间线
    func openTimeline() {
        let viewController = MyDaySingleDateTimelineViewController(date: Date())
        let navController = UINavigationController(rootViewController: viewController)
        navController.show()
    }
}
