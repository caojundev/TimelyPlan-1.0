//
//  ThemeKey+Config.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/24.
//

import Foundation

extension ThemeKey {
    static let normal: ThemeKey = "normal"
    static let selected: ThemeKey = "selected"
    static let highlighted: ThemeKey = "highlighted"
    
    static let tint: ThemeKey = "tint"
    static let background: ThemeKey = "background"
    static let separator: ThemeKey = "separator"
    
    static let title: ThemeKey = "title"
    static let subtitle: ThemeKey = "subtitle"
    
    static let sidebar: ThemeKey = "sidebar"
    static let navigationBar: ThemeKey = "navigationBar"
    static let insetGroupedTable: ThemeKey = "insetGroupedTable"
    static let sectionHeader: ThemeKey = "sectionHeader"
    static let sectionFooter: ThemeKey = "sectionFooter"
    static let cell: ThemeKey = "cell"
    
    // MARK: - 组合键值
    static let backgroundNormal: ThemeKey = background / normal
    static let backgroundSelected: ThemeKey = background / selected
    
    static let insetGroupedTableCell: ThemeKey = insetGroupedTable / cell
    static let insetGroupedTableCellTitle: ThemeKey = insetGroupedTableCell / title
    static let insetGroupedTableCellSubtitle: ThemeKey = insetGroupedTableCell / subtitle
    static let insetGroupedTableCellBackground: ThemeKey = insetGroupedTableCell / background
    static let insetGroupedTableCellBackgroundNormal: ThemeKey = insetGroupedTableCell / backgroundNormal
    static let insetGroupedTableCellBackgroundSelected: ThemeKey = insetGroupedTableCell / backgroundSelected
    
    static let insetGroupedTableSectionHeader: ThemeKey = insetGroupedTable / sectionHeader
    static let insetGroupedTableSectionHeaderTitle: ThemeKey = insetGroupedTableSectionHeader / title
}
