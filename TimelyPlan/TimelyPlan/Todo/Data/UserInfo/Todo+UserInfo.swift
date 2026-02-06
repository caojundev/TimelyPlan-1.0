//
//  Todo+UserInfo.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/28.
//

import Foundation

let SetKeyUserInfo = "UserInfo"

extension Todo {
    
    /// 获取用户信息
    static func getUserInfo() -> TodoUserInfo {
        let userInfo: TodoUserInfo? = TPSettingAgent.shared.value(forKey: SetKeyUserInfo)
        return userInfo ?? TodoUserInfo()
    }
    
    /// 获取列表信息
    func listInfo(for list: TodoListRepresentable) -> TodoListInfo? {
        return userInfo.info(for: list)
    }
    
    /// 设置列表信息
    func setListInfo(_ info: TodoListInfo?, for list: TodoListRepresentable) {
        userInfo.setInfo(info, for: list)
        TPSettingAgent.shared.set(value: userInfo, forKey: SetKeyUserInfo)
        TPSettingAgent.shared.synchronize()
    }
    
}
