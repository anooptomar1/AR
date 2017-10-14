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
                //用于控制动画效果
                SCNTransaction.begin()
                animation(node: node)
                SCNTransaction.completionBlock = {
                    node.removeFromParentNode()
                }
                SCNTransaction.commit()
                
            }
        }
    }
    
    func addNode() {
        let jellyfishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")!
        //recursively 是否遍历所有节点，false为只遍历根节点的直接节点
        let jellyfishNode = jellyfishScene.rootNode.childNode(withName: "Jellyfish", recursively: false)!
        jellyfishNode.position = randomPostion()
        scnView.scene.rootNode.addChildNode(jellyfishNode)
    }
    
    func randomPostion() -> SCNVector3 {
        let spaceHeight: Float = 1.0
        let spceWidth: Float = 1.0
        let spaceLength: Float = 1.0
        
        let x = random(spaceLength)
        let y = random(spaceHeight)
        let z = random(spceWidth)
        
        return SCNVector3(x, y, z)
    }
    
    func animation(node: SCNNode) {
        if !node.animationKeys.isEmpty { return }
        let animation = CABasicAnimation(keyPath: "scale")
        animation.fromValue = SCNVector3(0.1, 0.1, 0.1)
        animation.toValue = SCNVector3(0.15, 0.15, 0.15)
        animation.autoreverses = true
        animation.repeatCount = 5
        animation.duration = 0.1
        node.addAnimation(animation, forKey: nil)
    }
    
    @IBAction func play(_ sender: UIButton) {
        addNode()
    }
    
    
    @IBAction func stop(_ sender: UIButton) {
        scnView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        scnView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
}

func random(_ number: Float) -> Float{
    var value = Float(arc4random() % (UInt32(number) * 10)) * 0.1
    if (arc4random() % 100) % 2 == 0 {
        value = -value
    }
    return value
}



