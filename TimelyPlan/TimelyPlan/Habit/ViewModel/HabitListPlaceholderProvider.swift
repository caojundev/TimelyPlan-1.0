//
//  HabitListPlaceholderProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/2.
//

import Foundation

class HabitListPlaceholderProvider: TPPlaceholderProviding {
    
    /// 当前列表状态
    var state: TPListLoadingState = .initialLoading
    
    var emptyImage: UIImage?
    
    var emptyTitle: String?
    
    /// 默认占位视图
    func newEmptyPlaceholderView() -> TPDefaultPlaceholderView {
        let view = TPDefaultPlaceholderView()
        view.image = emptyImage
        view.title = emptyTitle
        view.titleColor = .lightGray
        return view
    }
    
    /// 默认占位视图
    func newLoadingPlaceholderView() -> TPDefaultPlaceholderView {
        let view = TPDefaultPlaceholderView()
        view.titleColor = .lightGray
        view.title = resGetString("Loading......")
        return view
    }
    
    func placeholderView() -> UIView? {
        if state == .initialLoading || state == .loading {
            return newLoadingPlaceholderView()
        } else {
            return newEmptyPlaceholderView()
        }
    }
}
