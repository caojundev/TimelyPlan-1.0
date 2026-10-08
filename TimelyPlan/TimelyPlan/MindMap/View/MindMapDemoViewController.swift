//
//  MindMapDemoViewController.swift
//  MindMapKit
//
//  最简接入示例：纯 UIKit，无 Auto Layout，无 Storyboard。
//  直接把 MindMapCanvasView 铺满即可，通常这是 App 中唯一需要写的 5 行代码。
//

import UIKit

public class MindMapDemoViewController: UIViewController {

    private lazy var canvas = MindMapCanvasView(metrics: .init(), palette: .init())

    /// 可选：主题管理器。默认跟随系统深 / 浅色自动换肤。
    /// 想切内置主题：`themes.apply(.paper)`；想强制深色：`themes.appearanceOverride = .dark`。
    private let themes = MindMapThemeManager(theme: .classic)

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = canvas.palette.background

        canvas.frame = view.bounds
        canvas.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(canvas)

        canvas.setRoot(MindMapSampleData.projectFlow())

        // 可选：监听展开 / 收起
        canvas.onNodeToggled = { node in
            print("toggled: \(node.text) expanded=\(node.isExpanded)")
        }

        // 可选：接入主题。管理器只依赖 MindMapThemeHost 协议，画布不需要知道主题的
        // 存在；系统深浅色切换时会自动套用对应配色并回调下面的 onChange。
        // 注意先装回调再 attach，这样接入时的首次套用也能收到。
        themes.onChange = { [weak self] palette, appearance in
            guard let self = self else { return }
            self.view.backgroundColor = palette.background
            // 外部按钮 / 文字也按当前明暗换色（这里以 tintColor 为例）：
            //   switch appearance { case .dark: …; case .light: … }
            self.view.tintColor = appearance == .dark ? .white : .black
        }
        themes.attach(canvas)
    }

    public override var prefersStatusBarHidden: Bool { true }
}
