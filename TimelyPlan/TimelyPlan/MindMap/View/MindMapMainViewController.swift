//
//  MindMapMainViewController.swift
//  MindMapKit
//

import Foundation
import UIKit

public class MindMapMainViewController: UIViewController {

    private lazy var canvas = MindMapCanvasView(metrics: .init(), palette: .init())

    /// 可选：主题管理器。默认跟随系统深 / 浅色自动换肤。
    /// 想切内置主题：`themes.apply(.paper)`；想强制深色：`themes.appearanceOverride = .dark`。
    private let themes = MindMapThemeManager(theme: .classic)

    // MARK: - 顶部工具栏

    /// 工具栏内容高度（不含安全区）。
    private let toolbarHeight: CGFloat = 44

    /// 工具栏左侧内边距。
    private let toolbarLeadingInset: CGFloat = 12

    private lazy var toolbar = UIView()

    /// 关闭按钮：图标 chevron_left_24，颜色跟随主题换肤。
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = resGetImage("chevron_left_24")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(clickClose), for: .touchUpInside)
        return button
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = canvas.palette.background

        canvas.frame = view.bounds
        canvas.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(canvas)

        setupToolbar()

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
            // 顶部工具栏关闭按钮跟随主题换色。
            self.closeButton.tintColor = palette.text
        }
        themes.attach(canvas)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutToolbar()
    }
    
    // MARK: - 工具栏

    private func setupToolbar() {
        toolbar.backgroundColor = .clear
        toolbar.addSubview(closeButton)
        view.addSubview(toolbar)
    }

    private func layoutToolbar() {
        let safeTop = view.safeAreaInsets.top
        toolbar.frame = CGRect(x: 0,
                               y: 0,
                               width: view.bounds.width,
                               height: safeTop + toolbarHeight)
        closeButton.frame = CGRect(x: toolbarLeadingInset,
                                   y: safeTop,
                                   width: toolbarHeight,
                                   height: toolbarHeight)
    }

    // MARK: - Event Response

    @objc private func clickClose() {
        dismiss(animated: true, completion: nil)
    }
}
