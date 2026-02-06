//
//  AppLaunchViewContrtoller.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/24.
//

import Foundation
import UIKit

class AppLaunchViewContrtoller: UIViewController {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = resGetImage("LaunchLogo")
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        view.addSubview(imageView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imageView.size = CGSize(width: 140.0, height: 140.0)
        imageView.alignCenter()
    }
}
