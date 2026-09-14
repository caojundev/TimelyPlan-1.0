//
//  FlipClockMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/13.
//

import Foundation
import UIKit

/// 翻页时钟，实时显示当前时间
class FlipClockMainViewController: TPViewController {
    
    /// 顶部栏
    lazy var topbar: FocusFlipClockTopbar = {
        let bar = FocusFlipClockTopbar()
        bar.title = resGetString("Flip Clock")
        bar.didClickClose = { [weak self] in
            self?.clickClose()
        }
        
        return bar
    }()
    
    /// 时钟视图
    lazy var clockView: FlipClockView = {
        let view = FlipClockView(frame: view.bounds)
        view.autoHideHour = false
        return view
    }()
    
    /// 秒级更新器
    private let updater = TPSecondUpdater()
    
    let topbarHeight = 60.0
    let topbarBottomMargin = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(topbar)
        view.addSubview(clockView)
        updater.start { [weak self] in
            self?.updateClock()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeLayoutFrame()
        
        topbar.width = layoutFrame.width
        topbar.height = topbarHeight
        topbar.origin = layoutFrame.origin
        
        clockView.width = layoutFrame.width
        clockView.height = layoutFrame.maxY - topbar.bottom - topbarBottomMargin
        clockView.left = layoutFrame.minX
        clockView.top = topbar.bottom + topbarBottomMargin
    }
    
    override var themeBackgroundColor: UIColor? {
        return .black
    }
    
    // MARK: - Clock
    
    /// 当前时间对应的当天已过秒数
    private var currentInterval: TimeInterval {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        return TimeInterval(hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second)
    }
    
    /// 更新翻页时钟
    private func updateClock() {
        clockView.update(with: currentInterval)
    }
    
    
    // MARK: - Event Response
    func clickClose() {
        dismiss(animated: true)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeRight]
    }
}
