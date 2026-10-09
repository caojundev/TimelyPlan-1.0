import SwiftUI

/// 一键可用的付费墙视图。业务侧可零成本接入，也可参照它自建 UI。
///
/// ```swift
/// IAPPaywallView(manager: iap) { result in
///     print(result.message)
/// }
/// ```
@available(iOS 15.0, *)
public struct IAPPaywallView: View {

    @ObservedObject private var manager: IAPManager
    private let onFinish: ((IAPPurchaseResult) -> Void)?

    @State private var purchasingID: String?
    @State private var alertMessage: String?

    public init(manager: IAPManager = .shared, onFinish: ((IAPPurchaseResult) -> Void)? = nil) {
        self.manager = manager
        self.onFinish = onFinish
    }

    public var body: some View {
        Group {
            if manager.products.isEmpty {
                if manager.isLoadingProducts {
                    ProgressView("正在加载商品…")
                } else {
                    emptyState
                }
            } else {
                productList
            }
        }
        .task { await manager.loadProducts() }
        .alert("提示", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("好的", role: .cancel) { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    // MARK: - 子视图

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart.badge.questionmark")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("暂无可用商品")
                .foregroundColor(.secondary)
            Button("重新加载") { Task { await manager.loadProducts() } }
                .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var productList: some View {
        List {
            if manager.entitlement.isActive {
                Section {
                    activeBanner
                }
            }

            Section("会员方案") {
                ForEach(manager.products) { item in
                    productRow(item)
                }
            }

            Section {
                Button {
                    Task { await restore() }
                } label: {
                    HStack {
                        Spacer()
                        Text("恢复购买").font(.subheadline)
                        Spacer()
                    }
                }
            } footer: {
                Text("已购买过的用户请点击恢复。订阅可在系统「设置 → Apple ID → 订阅」中管理。")
                    .font(.caption)
            }
        }
        .listStyle(.insetGrouped)
    }

    private var activeBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
            VStack(alignment: .leading, spacing: 2) {
                Text("会员已生效").font(.subheadline.weight(.semibold))
                if let expiry = manager.entitlement.subscriptionExpiryDate {
                    Text("到期时间：\(expiry.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption).foregroundColor(.secondary)
                }
            }
        }
    }

    private func productRow(_ item: IAPStoreProduct) -> some View {
        Button {
            Task { await purchase(item) }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.displayName).font(.body.weight(.semibold))
                    HStack(spacing: 6) {
                        Text(item.subscriptionPeriodText ?? "永久")
                        if let trial = item.freeTrialText {
                            Text(trial)
                                .font(.caption2)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.15))
                                .foregroundColor(.accentColor)
                                .cornerRadius(4)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)

                    if !item.description.isEmpty {
                        Text(item.description)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                Spacer()
                if purchasingID == item.id {
                    ProgressView()
                } else {
                    Text(item.displayPrice).fontWeight(.semibold)
                }
            }
        }
        .disabled(purchasingID != nil)
    }

    // MARK: - 动作

    private func purchase(_ item: IAPStoreProduct) async {
        purchasingID = item.id
        let result = await manager.purchase(item)
        purchasingID = nil

        if case .success = result {} else { alertMessage = result.message }
        onFinish?(result)
    }

    private func restore() async {
        let snapshot = await manager.restore()
        if !snapshot.isActive {
            alertMessage = "未找到可恢复的购买记录。"
        }
        onFinish?(.success(entitlement: snapshot))
    }
}
