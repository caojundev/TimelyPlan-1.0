//
//  TPPlaceholderProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/29.
//

import Foundation
import UIKit

enum TPListLoadingState {
    case initialLoading   // 初次加载
    case loaded
}

protocol TPPlaceholderProviding: AnyObject {
    /// 占位视图
    func placeholderView() -> UIView?
}

class TPLoadableListPlaceholderProvider: TPPlaceholderProviding {
    
    /// 当前列表状态
    var state: TPListLoadingState = .initialLoading
    
    var emptyTitle: String? {
        get {
            return emptyPlaceholderView.title
        }
        
        set {
            emptyPlaceholderView.title = newValue
        }
    }
    
    var emptyImage: UIImage? {
        get {
            return emptyPlaceholderView.image
        }
        
        set {
            emptyPlaceholderView.image = newValue
        }
    }
    
    /// 默认占位视图
    lazy var emptyPlaceholderView: TPDefaultPlaceholderView = {
        let view = TPDefaultPlaceholderView()
        view.titleColor = .lightGray
        return view
    }()
    
    /// 默认占位视图
    lazy var loadingPlaceholderView: TPDefaultPlaceholderView = {
        let view = TPDefaultPlaceholderView()
        view.titleColor = .lightGray
        view.title = resGetString("Loading......")
        return view
    }()
    
    func placeholderView() -> UIView? {
        if state == .initialLoading {
            return loadingPlaceholderView
        } else {
            return emptyPlaceholderView
        }
        
    }
}
