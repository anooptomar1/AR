//
//  ViewController.swift
//  Portal
//
//  Created by 张思槐 on 2017/10/26.
//  Copyright © 2017年 zhangsihuai. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    var configuration = ARWorldTrackingConfiguration()

    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var scnView: ARSCNView! {
        didSet{
            scnView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scnView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        configuration.planeDetection = .horizontal
        scnView.session.run(configuration)
        
    }


}

extension ViewController: ARSCNViewDelegate {
    
}

