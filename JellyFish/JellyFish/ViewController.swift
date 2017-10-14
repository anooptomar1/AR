//
//  ViewController.swift
//  JellyFish
//
//  Created by 张思槐 on 2017/10/14.
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
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handlerTap(_:)))
        scnView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc func handlerTap(_ gesture: UITapGestureRecognizer) {
        let view = gesture.view as! ARSCNView
        let location = gesture.location(in: view)
        let hitTest = view.hitTest(location)
        if !hitTest.isEmpty {
            let result = hitTest.first
            if let node = result?.node {
                animation(node: node)
            }
        }
    }
    
    func addNode() {
        let jellyfishScene = SCNScene(named: "scn.scnassets/Jellyfish.scn")!
        //recursively 是否遍历所有节点，false为只遍历根节点的直接节点
        let jellyfishNode = jellyfishScene.rootNode.childNode(withName: "Jellyfish", recursively: false)!
        jellyfishNode.position = SCNVector3(0, 0, 1)
        scnView.scene.rootNode.addChildNode(jellyfishNode)
    }
    
    func animation(node: SCNNode) {
        if !node.animationKeys.isEmpty { return }
        let animation = CABasicAnimation(keyPath: "scale")
        animation.fromValue = SCNVector3(1, 1, 1)
        animation.toValue = SCNVector3(1.5, 1.5, 1.5)
        animation.repeatCount = 5
        animation.duration = 0.1
        node.addAnimation(animation, forKey: nil)
    }
    
    @IBAction func play(_ sender: UIButton) {
        addNode()
    }
    
    
    @IBAction func stop(_ sender: UIButton) {
    }


}



