//
//  ViewController.swift
//  Earth
//
//  Created by 张思槐 on 2017/10/11.
//  Copyright © 2017年 zhangsihuai. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    let configuration = ARWorldTrackingConfiguration()
    
    @IBOutlet weak var scnView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scnView.session.run(configuration)
        scnView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        //光源
        scnView.autoenablesDefaultLighting = true
        
        //创建地球
        let earthNode = SCNNode()
        
        //地球贴图
        earthNode.geometry = SCNSphere(radius: 0.3)
        earthNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "earth_daymap")
        earthNode.geometry?.firstMaterial?.emission.contents = UIImage(named: "earth_clouds")
        earthNode.geometry?.firstMaterial?.specular.contents = UIImage(named: "earth_specular")
        earthNode.geometry?.firstMaterial?.normal.contents = UIImage(named: "earth_normal")
        
        //创建自转动作
        let action = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 8)
        let rotaionAction = SCNAction.repeatForever(action)
        earthNode.runAction(rotaionAction)
        
        earthNode.position = SCNVector3(0,0,-1)
        
        scnView.scene.rootNode.addChildNode(earthNode)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

