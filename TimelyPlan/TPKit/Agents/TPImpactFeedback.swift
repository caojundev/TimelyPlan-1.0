//
//  TPImpactFeedback.swift
//  TimelyPlan
//
//  Created by caojun on 2023/4/6.
//

import Foundation
import UIKit

class TPImpactFeedback {
    
    /// 共享数据管理对象
    static let feedback = TPImpactFeedback()
    
    /// 是否可用
    public var enabled = true
    
    /// 类方法
    static func impactWithStyle(_ style: UIImpactFeedbackGenerator.FeedbackStyle){
        TPImpactFeedback.feedback.impactWithStyle(style)
    }
 
    static func impactWithSoftStyle(){
        TPImpactFeedback.impactWithStyle(.soft)
    }
    
    static func impactWithLightStyle(){
        TPImpactFeedback.impactWithStyle(.light)
    }
    
    static func impactWithMediumStyle(){
        TPImpactFeedback.impactWithStyle(.medium)
    }

    static func impactWithHeavyStyle(){
        TPImpactFeedback.impactWithStyle(.heavy)
    }

    static func impactWithRigidStyle(){
        TPImpactFeedback.impactWithStyle(.rigid)
    }
    
    /// 实例方法
    func impactWithLightStyle() {
        impactWithStyle(.light)
    }
    
    func impactWithMediumStyle() {
        impactWithStyle(.medium)
    }
    
    func impactWithHeavyStyle() {
        impactWithStyle(.heavy)
    }
    
    func impactWithSoftStyle() {
        impactWithStyle(.soft)
    }
    
    func impactWithRigidStyle() {
        impactWithStyle(.rigid)
    }
    
    private func impactWithStyle(_ style: UIImpactFeedbackGenerator.FeedbackStyle){
        if !enabled {
            return
        }
        
        let feedBackGenertor = UIImpactFeedbackGenerator(style: style)
        feedBackGenertor.impactOccurred()
    }

    // MARK: - Feedback
    static func feedbackWithSuccessStyle(){
        TPImpactFeedback.feedback.feedbackWithSuccessStyle()
    }
    
    static func feedbackWithWarningStyle(){
        TPImpactFeedback.feedback.feedbackWithWarningStyle()
    }
    
    static func feedbackWithErrorStyle(){
        TPImpactFeedback.feedback.feedbackWithErrorStyle()
    }
    
    func feedbackWithSuccessStyle(){
        feedbackWithStyle(.success)
    }
    
    func feedbackWithWarningStyle(){
        feedbackWithStyle(.warning)
    }
    
    func feedbackWithErrorStyle(){
        feedbackWithStyle(.error)
    }
    
    private func feedbackWithStyle(_ style: UINotificationFeedbackGenerator.FeedbackType){
        if !enabled {
            return
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
}
