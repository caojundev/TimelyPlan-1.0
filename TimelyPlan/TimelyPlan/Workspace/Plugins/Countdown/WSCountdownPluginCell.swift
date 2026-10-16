//
//  WSCountdownPluginCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation
import UIKit

class WSCountdownSmallPluginCell: WorkspacePluginCell {

    override var pluginBackgroundColor: UIColor {
        return .primary
    }
    
    override func makePluginContentView() -> WorkspacePluginContentView! {
        return WSCountdownPluginContentView()
    }
}

class WSCountdownMediumPluginCell: WorkspacePluginCell {

    override var pluginBackgroundColor: UIColor {
        return .orangePrimary
    }
    
    override func makePluginContentView() -> WorkspacePluginContentView! {
        return WSCountdownPluginContentView()
    }
}

class WSCountdownLargePluginCell: WorkspacePluginCell {

    override var pluginBackgroundColor: UIColor {
        return .purplePrimary
    }
    
    override func makePluginContentView() -> WorkspacePluginContentView! {
        return WSCountdownPluginContentView()
    }
    
}
