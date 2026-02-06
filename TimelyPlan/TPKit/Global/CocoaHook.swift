//
//  CocoaHook.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/5.
//

import Foundation

func swizzleInstanceMethod(_ aClass: AnyClass, _ originalSel: Selector, _ newSel: Selector) {
    guard
        let originalMethod = class_getInstanceMethod(aClass, originalSel),
        let newMethod = class_getInstanceMethod(aClass, newSel)
    else {
        return
    }
    
    let didAddMethod = class_addMethod(aClass, originalSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))
    
    if didAddMethod {
        class_replaceMethod(aClass, newSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    } else {
        method_exchangeImplementations(originalMethod, newMethod)
    }
}

func swizzleClassMethod(_ aClass: AnyClass, _ originalSel: Selector, _ newSel: Selector) {
    guard let metaClass = object_getClass(aClass) else {
        return
    }
    
    swizzleInstanceMethod(metaClass, originalSel, newSel)
}
