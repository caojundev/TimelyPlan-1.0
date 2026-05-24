//
//  TPCollectionKeyboardAdjuster.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/24.
//

import Foundation
import UIKit

class TPCollectionKeyboardAdjuster {
    
    /// 绑定的滚动视图
    private weak var collectionView: UICollectionView?
    
    var isEnabled: Bool = false {
        didSet {
            if isEnabled {
                collectionView?.addKeyboardNotification()
            } else {
                collectionView?.removeKeyboardNotification()
            }
        }
    }
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    deinit {
        collectionView?.removeKeyboardNotification()
    }
}

