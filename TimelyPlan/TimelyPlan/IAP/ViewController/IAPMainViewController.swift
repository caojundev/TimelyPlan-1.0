//
//  IAPMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/19.
//

import Foundation
import UIKit

class IAPMainViewController: TPViewController {
    
    private let contentView = UIScrollView()
    private let continueView = IAPContinueView()
    
    private let productSelectorView = IAPProductSelectorView()
    
    private let benefitsHeaderLabel = UILabel()
    private let benefitsTableView = MembershipBenefitsTableView()
    private let actionsView = IAPActionsView()
    private let reminderView = IAPReminderView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Upgrade to Premium")
        view.addSubview(contentView)
        view.addSubview(continueView)
        setupContentSubviews()
    }
    
    private func setupContentSubviews() {
        // 商品选择器
        let products = IAPTestData.standardProducts
        productSelectorView.configure(products: products, defaultSelectedIndex: 0)
        productSelectorView.onProductSelected = { [weak self] index, product in
            debugPrint("已选中: \(product.title) (\(product.priceText))")
        }
        
        contentView.addSubview(productSelectorView)

        setupBenefitsView()
        setupActionsView()
        setupReminderView()
    }

    private func setupBenefitsView() {
        // 分组小标题
        benefitsHeaderLabel.text = "功能畅享特权"
        benefitsHeaderLabel.textColor = MembershipColor.sectionOrange
        benefitsHeaderLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        contentView.addSubview(benefitsHeaderLabel)
        
        // 测试数据
        benefitsTableView.rows = [
            BenefitRow(title: "日历视图",     freeValue: "基础",   proValue: "月/周/日/3日"),
            BenefitRow(title: "时间段",       freeValue: nil,      proValue: nil),
            BenefitRow(title: "持续提醒",     freeValue: nil,      proValue: nil),
            BenefitRow(title: "关联 Notion",  freeValue: nil,      proValue: nil),
            BenefitRow(title: "关联微信",     freeValue: nil,      proValue: nil),
            BenefitRow(title: "AI 语音添加",  freeValue: nil,      proValue: nil),
            BenefitRow(title: "AI 录音总结",  freeValue: nil,      proValue: nil),
            BenefitRow(title: "小组件",       freeValue: "基础",   proValue: "无限制"),
            BenefitRow(title: "外观主题",     freeValue: "基础",   proValue: "无限制"),
            BenefitRow(title: "数据统计",     freeValue: "基础",   proValue: "无限制"),
            BenefitRow(title: "更多功能",     freeValue: nil,      proValue: nil),
            // 测试长文本换行（验证动态行高）
            BenefitRow(
                title: "这是一个非常长的权益名称，用来测试首列文本换行时行高是否会动态增加，验证最小和最大高度约束是否生效",
                freeValue: "基础",
                proValue: "无限制"
            ),
        ]
        
        benefitsTableView.onContentHeightChanged = { [weak self] _ in
            guard let self = self else { return }
            self.view.animateLayout(withDuration: 0.4)
        }
        
        contentView.addSubview(benefitsTableView)
    }
    
    private func setupActionsView() {
        // 设置按钮点击回调
        actionsView.onRestorePurchasesTapped = {
            print("用户点击了恢复购买")
            // 在这里实现恢复购买逻辑
            // 例如：调用 StoreKit 的 restorePurchases()
        }

        actionsView.onRedeemCodeTapped = {
            print("用户点击了兑换代码")
            // 在这里实现兑换代码逻辑
            // 例如：调用 StoreKit 的 presentCodeRedemptionSheet()
        }

        contentView.addSubview(actionsView)
    }
    
    private func setupReminderView() {
        reminderView.onTapPrivacy = { print("打开隐私政策") }
        reminderView.onTapTerms   = { print("打开服务条款") }
        contentView.addSubview(reminderView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contentView.frame = view.bounds
        
        continueView.width = view.width
        continueView.sizeToFit()
        continueView.bottom = view.height
        
        let margin = 16.0
        let layoutWidth = view.width - 2 * margin
        let selectorHeight = productSelectorView.recommendedHeight()
        productSelectorView.frame = CGRect(
            x: margin,
            y: 20,
            width: layoutWidth,
            height: selectorHeight
        )
        
        benefitsHeaderLabel.frame = CGRect(
            x: margin,
            y: productSelectorView.bottom + 30.0,
            width: layoutWidth,
            height: 24.0
        )
        
        let benefitsHeight = benefitsTableView.contentHeight
        benefitsTableView.frame = CGRect(
            x: margin,
            y: benefitsHeaderLabel.bottom + 15.0,
            width: layoutWidth,
            height: benefitsHeight
        )
  
        let constraintSize = CGSize(width: layoutWidth, height: .greatestFiniteMagnitude)
        let actionsViewSize = actionsView.sizeThatFits(constraintSize)
        actionsView.frame = CGRect(
            x: margin,
            y: benefitsTableView.bottom + 10.0,
            width: layoutWidth,
            height: actionsViewSize.height
        )
        
        let reminderViewSize = reminderView.sizeThatFits(constraintSize)
        reminderView.frame = CGRect(
            x: margin,
            y: actionsView.bottom + 10.0,
            width: layoutWidth,
            height: reminderViewSize.height
        )
        
        contentView.contentSize = CGSize(width: view.bounds.width,
                                         height: reminderView.bottom)
        contentView.contentInset = UIEdgeInsets(bottom: continueView.height)
    }
    
    override var themeBackgroundColor: UIColor? {
        return UIColor(red: 0.07, green: 0.07, blue: 0.08, alpha: 1)
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return themeBackgroundColor
    }

}
