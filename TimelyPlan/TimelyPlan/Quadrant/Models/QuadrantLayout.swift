//
//  QuadrantLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/11.
//

import Foundation

/// 象限布局
struct QuadrantLayout: Codable, Equatable {

    /// 自定义象限顺序
    var quadrants: [Quadrant]?
    
    /// 标题位置
    var titlePosition: QuadrantTitlePosition? = .top
    
    func getTitlePosition() -> QuadrantTitlePosition {
        return titlePosition ?? .top
    }
    
    func getQuadrants() -> [Quadrant] {
        guard let orderedQuadrants = quadrants, Set(orderedQuadrants) == Set(Quadrant.allCases) else {
            return Quadrant.allCases
        }
        
        let results = Quadrant.allCases.sorted { lQuadrant, rQuadrant in
            let lIndex = quadrants?.firstIndex(of: lQuadrant) ?? 0
            let rIndex = quadrants?.firstIndex(of: rQuadrant) ?? 0
            return lIndex <= rIndex
        }
        
        return results
    }
}
