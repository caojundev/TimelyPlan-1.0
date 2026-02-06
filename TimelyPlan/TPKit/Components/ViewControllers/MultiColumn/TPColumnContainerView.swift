//
//  TPColumnContainerView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/11.
//

import Foundation
import UIKit

protocol TPColumnContainerViewDelegate: AnyObject {
    /// 点击遮罩
    func columnContainerViewDidClickMask(_ containerView: TPColumnContainerView)
}

class TPColumnContainerView: UIView {
    
    weak var delegate: TPColumnContainerViewDelegate?
    
    var viewController: UIViewController? {
        didSet {
            guard viewController != oldValue else {
                return
            }
            
            let shouldRemoveOld = oldValue?.view.isDescendant(of: self) ?? false
            if shouldRemoveOld {
                oldValue?.view.removeFromSuperview()
            }
            
            if let viewController = viewController {
                viewController.loadViewIfNeeded()
                viewController.view.frame = self.bounds
                self.insertSubview(viewController.view, at: 0)
            }
        }
    }

    var coverMaskAlpha: CGFloat = 0.0 {
        didSet {
            if coverMaskAlpha > 0.0, !self.coverMaskView.isDescendant(of: self) {
                self.addCoverMaskView(with: coverMaskAlpha)
            } else if coverMaskAlpha == 0.0 {
                self.coverMaskView.removeFromSuperview()
            } else {
                self.coverMaskView.alpha = coverMaskAlpha
            }
        }
    }
    
    /// 遮罩视图
    lazy var coverMaskView: UIView = {
        let view = UIView(frame: self.bounds)
        view.backgroundColor = Color(0x000000, 0.5)
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTap(_:)))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(recognizer)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = .systemBackground
        self.separatorColor = Color(0x888888, 0.1)
        self.separatorPosition = .left
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        viewController?.view.frame = bounds
        coverMaskView.frame = bounds
    }
    
    func enableUserInteraction(animated: Bool = true) {
        self.viewController?.view.isUserInteractionEnabled = true
        guard self.coverMaskView.isDescendant(of: self) else {
            return
        }
        
        guard animated else {
            self.coverMaskView.removeFromSuperview()
            return
        }
 
        self.coverMaskView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .beginFromCurrentState) {
            self.coverMaskView.alpha = 0.0
        } completion: { _ in
            self.coverMaskView.removeFromSuperview()
        }
    }

    func disableUserInteraction(animated: Bool = true) {
        self.coverMaskView.layer.removeAllAnimations()
        self.viewController?.view.isUserInteractionEnabled = false
        if !self.coverMaskView.isDescendant(of: self) {
            self.coverMaskView.alpha = coverMaskAlpha
            self.addSubview(self.coverMaskView)
        }

        let animations = {
            self.coverMaskView.alpha = 1.0
        }
        
        guard animated else {
            animations()
            return
        }
        
        self.coverMaskView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .beginFromCurrentState,
                       animations: animations,
                       completion: nil)
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        delegate?.columnContainerViewDidClickMask(self)
    }
    
    func addCoverMaskView(with alpha: CGFloat) {
        coverMaskView.alpha = alpha
        addSubview(coverMaskView)
    }
}
