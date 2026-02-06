//
//  GlobalFunctions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/5.
//

import Foundation
import UIKit

/// 返回一个合法的进度值
func validatedProgress(_ value: CGFloat) -> CGFloat {
    return max(0.0, min(value, 1.0))
}

/// 在一段时间间隔后在主线程调用回调
func callback(after interval: TimeInterval, block: @escaping()->Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval) {
        block()
    }
}

/// 交换两个变量的值
func swapValues<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

/// 返回一个范围内的合法值
func clampValue<T: Comparable>(_ value: inout T, _ minValue: T, _ maxValue: T) {
    value = max(minValue, min(value, maxValue))
}

func clampValue<T: Comparable>(_ value: inout T, within range: ClosedRange<T>) {
    value = max(range.lowerBound, min(value, range.upperBound))
}

/**
 执行一段代码块，并在执行过程中禁用隐式动画。

 该函数通过使用 `CATransaction` 来临时禁用 Core Animation 的隐式动画效果，确保在 `actions` 闭包中的代码执行时不会触发不必要的动画。

 - Parameter actions: 一个闭包，包含需要在不触发隐式动画的情况下执行的代码。
 */
func executeWithoutAnimation(_ actions: () -> Void) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    actions()
    CATransaction.commit()
}
