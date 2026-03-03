//
//  HabitTaskStatusView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/15.
//

import Foundation
import UIKit

class HabitTaskStatusView: UIView {
    
    /// 任务状态
    var status: HabitTaskStatus = .notStarted
    
    var rotation: CGFloat = 0.0
    var contentView: UIView!
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView = UIView()
        addSubview(contentView)
        
        imageView = UIImageView()
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.transform = CGAffineTransform.identity
        contentView.frame = bounds
        
        imageView.transform = CGAffineTransform.identity
        imageView.frame.size = CGSize(width: 20.0, height: 20.0)
        imageView.center = CGPoint(x: bounds.midX, y: 0)
        
        let rotation = degreesToRadians(-45.0)
        contentView.transform = CGAffineTransform(rotationAngle: rotation)
        imageView.transform = CGAffineTransform(rotationAngle: -rotation)
    }
    
    func setStatus(_ status: HabitTaskStatus, animated: Bool) {
        if self.status == status {
            return
        }
        
        self.status = status
        
        var imageName: String?
        switch status {
        case .completed:
            imageName = "HabitStatusSuccess_20pt"
        case .failed:
            imageName = "HabitStatusFailed_20pt"
        case .skipped:
            imageName = "HabitStatusSkipped_20pt"
        default:
            break
        }
        
        var image: UIImage?
        if let imageName = imageName {
            image = UIImage(named: imageName)
        }
        
        if !animated {
            imageView.image = image
            return
        }
        
        if let image = image {
            imageView.image = image
            layoutIfNeeded()
            
            let animation = CAKeyframeAnimation.scaleKeyframeAnimation(withDuration: 0.4)
            imageView.layer.add(animation, forKey: "scale")
            
            if status == .completed {
                TPFireworkLayer.showOnView(imageView, radius: 16.0)
            }
        } else {
            imageView.image = nil
        }
    }
    
    func setStatus(_ status: HabitTaskStatus) {
        setStatus(status, animated: false)
    }
}


