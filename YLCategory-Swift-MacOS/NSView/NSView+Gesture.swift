//
//  NSView+Gesture.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/21.
//

import Foundation
import AppKit

fileprivate var NSViewClickGestureHandlerKey = false
fileprivate var NSViewPanGestureHandlerKey = false
fileprivate var NSViewPressGestureHandlerKey = false

public extension NSView {
    
    // MARK: 添加点击手势
    func addClickGesture(_ handler: @escaping (NSView, NSClickGestureRecognizer) -> Void, delegate: (any NSGestureRecognizerDelegate)? = nil) {
        let gesture = NSClickGestureRecognizer(target: self, action: #selector(clickHandler(_ :)))
        if delegate != nil {
            gesture.delegate = delegate
        }
        addGestureRecognizer(gesture)
        clickGestureHandler = handler
    }
    // MARK: 添加拖动手势
    func addPanGesture(_ handler: @escaping (NSView, NSPanGestureRecognizer) -> Void, delegate: (any NSGestureRecognizerDelegate)? = nil) {
        let gesture = NSPanGestureRecognizer(target: self, action: #selector(panHandler(_ :)))
        if delegate != nil {
            gesture.delegate = delegate
        }
        addGestureRecognizer(gesture)
        panGestureHandler = handler
    }
    // MARK: 添加长按手势
    func addPressGesture(_ handler: @escaping (NSView, NSPressGestureRecognizer) -> Void, delegate: (any NSGestureRecognizerDelegate)? = nil) {
        let gesture = NSPressGestureRecognizer(target: self, action: #selector(pressHandler(_ :)))
        if delegate != nil {
            gesture.delegate = delegate
        }
        addGestureRecognizer(gesture)
        pressGestureHandler = handler
    }
    
    private var clickGestureHandler: ((NSView, NSClickGestureRecognizer) -> Void)? {
        get { objc_getAssociatedObject(self, &NSViewClickGestureHandlerKey) as? ((NSView, NSClickGestureRecognizer) -> Void) }
        set { objc_setAssociatedObject(self, &NSViewClickGestureHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    
    private var panGestureHandler: ((NSView, NSPanGestureRecognizer) -> Void)? {
        get { objc_getAssociatedObject(self, &NSViewPanGestureHandlerKey) as? ((NSView, NSPanGestureRecognizer) -> Void) }
        set { objc_setAssociatedObject(self, &NSViewPanGestureHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    
    private var pressGestureHandler: ((NSView, NSPressGestureRecognizer) -> Void)? {
        get { objc_getAssociatedObject(self, &NSViewPressGestureHandlerKey) as? ((NSView, NSPressGestureRecognizer) -> Void) }
        set { objc_setAssociatedObject(self, &NSViewPressGestureHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
  
    @objc private func clickHandler(_ gesture: NSClickGestureRecognizer) {
        clickGestureHandler?(self, gesture)
    }
    @objc private func panHandler(_ gesture: NSPanGestureRecognizer) {
        panGestureHandler?(self, gesture)
    }
    @objc private func pressHandler(_ gesture: NSPressGestureRecognizer) {
        pressGestureHandler?(self, gesture)
    }
}
