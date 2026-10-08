//
//  MindMapNode.swift
//  MindMapKit
//
//  数据模型层：与 UI / 布局 / 渲染完全解耦，可自由替换为 JSON / 网络数据源。
//

import UIKit

// MARK: - 数据源协议

/// 任意能提供思维导图结构的对象都可以驱动渲染。
/// 使用协议而非具体类型，方便接入 JSON、数据库等不同数据源。
public protocol MindMapNodeType: AnyObject {
    var nodeID: String { get }
    var text: String { get }
    var children: [MindMapNodeType] { get }
    /// 节点携带的类型化额外数据（勾选状态、图标信息…），交给对应的节点图层子类
    /// 配置自身。不提供时默认 nil，即文本节点 —— 纯结构型数据源无需改动。
    var content: MindMapNodeContent? { get }
}

// MARK: - 默认节点实现

/// 默认节点。轻量 class，避免多层结构体带来的写时复制开销。
public final class MindMapNode: MindMapNodeType {

    public let nodeID: String
    public var text: String
    /// 类型化额外数据。决定用哪个图层子类，以及那个图层怎么配置自己。
    public var content: MindMapNodeContent?
    public private(set) var children: [MindMapNodeType]

    /// 是否展开子节点。折叠状态保存在模型里，重算布局时不会丢失。
    public var isExpanded: Bool = true

    public init(id: String = UUID().uuidString,
                text: String,
                content: MindMapNodeContent? = nil,
                children: [MindMapNodeType] = []) {
        self.nodeID = id
        self.text = text
        self.content = content
        self.children = children
    }

    public func add(_ child: MindMapNodeType) {
        children.append(child)
    }
}

// MARK: - 辅助方法

public extension MindMapNodeType {

    /// 节点类型，由载荷决定；无载荷即文本节点。
    ///
    /// 之所以「推导」而不是「存储」：类型与载荷是同一件事的两种表述，只保留载荷
    /// 这一个事实来源，就不会出现「kind 说是待办、载荷却是图标」这种不一致。
    var kind: MindMapNodeKind { content?.kind ?? .text }

    /// 只返回当前需要参与布局的子节点（折叠状态下返回空数组）。
    var visibleChildren: [MindMapNodeType] {
        if let node = self as? MindMapNode {
            return node.isExpanded ? node.children : []
        }
        return children
    }

    /// 是否处于展开状态（纯结构型数据源默认视为展开）。
    var isExpanded: Bool {
        (self as? MindMapNode)?.isExpanded ?? true
    }

    var isLeaf: Bool { children.isEmpty }

    /// 深度优先遍历（含自身）。
    func forEachDepthFirst(_ body: (MindMapNodeType, Int) -> Void, depth: Int = 0) {
        body(self, depth)
        children.forEach { $0.forEachDepthFirst(body, depth: depth + 1) }
    }

    /// 仅遍历当前可见的子节点（折叠分支会被跳过）。
    func forEachVisibleDepthFirst(_ body: (MindMapNodeType, Int) -> Void, depth: Int = 0) {
        body(self, depth)
        visibleChildren.forEach { $0.forEachVisibleDepthFirst(body, depth: depth + 1) }
    }

    /// 按 nodeID 查找节点。
    func node(withID id: String) -> MindMapNodeType? {
        if nodeID == id { return self }
        for child in children {
            if let found = child.node(withID: id) { return found }
        }
        return nil
    }

    /// 从根开始的路径（含自身），用于追溯节点所属的一级分支颜色。
    func pathToNode(withID id: String, current: [MindMapNodeType] = []) -> [MindMapNodeType]? {
        let path = current + [self]
        if nodeID == id { return path }
        for child in children {
            if let found = child.pathToNode(withID: id, current: path) { return found }
        }
        return nil
    }
}
