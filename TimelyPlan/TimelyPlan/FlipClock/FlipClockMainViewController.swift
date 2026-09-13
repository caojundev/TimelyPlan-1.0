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
        let view = FlipClockView()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updater.start { [weak self] in
            self?.updateClock()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updater.stop()
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
        let windowScene = view.window?.windowScene
        dismiss(animated: true) {
            FlipClockMainViewController.restorePortraitOrientation(in: windowScene)
        }
    }
    
    /// 关闭翻页时钟后恢复竖屏，避免外部页面停留在横屏
    private static func restorePortraitOrientation(in windowScene: UIWindowScene?) {
        guard let windowScene = windowScene else {
            return
        }
        
        if #available(iOS 16.0, *) {
            #warning("iOS 16.0 打开注释")
//            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    
    // MARK: - Interface Orientation
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    /// 仅本视图控制器支持横屏和竖屏
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
}
