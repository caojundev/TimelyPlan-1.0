//
//  MindMapMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/8.
//

import Foundation
import UIKit

/// 思维导图预览：顶部工具栏 + 可拖拽 / 缩放的画布，跟随系统明暗自动换肤。
public class MindMapMainViewController: UIViewController {

    private lazy var canvas = MindMapCanvasView(metrics: .init(), palette: .init())

    /// 主题管理器。默认跟随系统深 / 浅色自动换肤。
    /// 想切内置主题：`themes.apply(.paper)`；想强制深色：`themes.appearanceOverride = .dark`。
    private let themes = MindMapThemeManager(theme: .classic)

    // MARK: - 内容

    /// 要展示的根节点。为 nil 时画布为空；赋值即可渲染一张导图
    /// （例如 `TodoMindMapPreviewer` 转换出来的列表导图）。
    public var rootNode: MindMapNodeType? {
        didSet {
            guard isViewLoaded, let rootNode = rootNode else { return }
            canvas.setRoot(rootNode)
        }
    }

    /// 便捷构造：直接指定要展示的根节点。
    public convenience init(root: MindMapNodeType) {
        self.init(nibName: nil, bundle: nil)
        self.rootNode = root
    }

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

        // 画布内容：未指定根节点时保持空白。
        if let rootNode = rootNode {
            canvas.setRoot(rootNode)
        }

        // 接入主题。管理器只依赖 MindMapThemeHost 协议，画布不需要知道主题的
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
