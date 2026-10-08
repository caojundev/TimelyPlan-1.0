//
//  MindMapSampleData.swift
//  MindMapKit
//
//  示例数据：与参考图结构一致，用于快速验证效果。
//
//  其中混入了两种非文本节点，用来演示节点类型机制：
//    · 待办节点 —— `MindMapTodoContent`，左侧勾选框，勾选状态在数据里；
//    · 图标节点 —— `MindMapIconContent`，左侧一个 `TPIcon`：图片图标与 Emoji 图标各一个。
//
//  ⚠️ nodeID 在整棵树内必须唯一。这里用文本作为 id 只是为了让示例可读；
//     真实接入时请使用业务侧的稳定唯一标识（如数据库主键、UUID），
//     因为同一文本完全可能出现在不同分支下。
//

import Foundation
import UIKit

public enum MindMapSampleData {

    public static func projectFlow() -> MindMapNode {
        MindMapNode(id: "root", text: "项目流程", children: [
            node("启动", [
                node("用户需求", [
                    node("产品定位", [
                        node("目标用户（给什么人用）"),
                        node("主要功能（用来干什么）"),
                        node("产品特色（竞争力）")
                    ]),
                    node("需求分析", [node("竞品分析，用户调研")]),
                    node("需求筛选", [
                        node("删除不合理的需求"),
                        node("是否符合产品定位"),
                        node("是否符合用户目标"),
                        node("需求优先级")
                    ])
                ]),
                node("商业价值"),
                node("技术可行性评估")
            ]),
            node("上线", [
                // 图标节点：资源图片（TPIcon.image）
                node("数据分析", content: MindMapIconContent(imageName: "checkmark_circle_fill_24",
                                                          tint: .systemOrange),
                     [node("集成 Flurry SDK")]),
                node("反馈优化", content: MindMapTodoContent()),
                node("需求提取", [node("隐性需求的深度挖掘")])
            ]),
            node("执行（时间、质量和成本的平衡）", [
                node("产品层面", [
                    node("需求文档", [
                        node("背景描述（简明）", [
                            node("项目开展原因"),
                            node("项目解决用户什么"),
                            node("项目价值体现")
                        ]),
                        node("用户画像", [node("用户特征说明")]),
                        node("项目各阶段时间规划"),
                        node("app 结构图 ★"),
                        node("业务流程图", [node("梳理用户使用的整个流程")]),
                        node("需求详细说明"),
                        node("数据埋点")
                    ]),
                    node("交互设计", [
                        node("线框图", [node("先忽略配色和交互")]),
                        node("页面流程图", [node("各个页面的连接和跳转")]),
                        node("原型图", [node("真机 app 界面")])
                    ]),
                    // 图标节点：Emoji（TPIcon.text）
                    node("UI 设计", content: MindMapIconContent(text: "😄", tint: .systemBlue))
                ]),
                node("编码实现", content: MindMapTodoContent(isDone: true)),
                node("测试", [
                    node("bug 管理工具"),
                    node("UI 和交互测试", [node("Python 检查尺寸程序，显示是否透明")])
                ])
            ])
        ])
    }

    // MARK: 构造辅助

    /// 用文本同时作为 id（仅示例用），并递归为子节点补齐唯一 id。
    ///
    /// `content` 用于挂上节点类型载荷（待办 / 图标…），不传即文本节点。
    private static func node(_ text: String,
                             content: MindMapNodeContent? = nil,
                             _ children: [MindMapNode] = []) -> MindMapNode {
        MindMapNode(id: text, text: text, content: content, children: children)
    }
}
