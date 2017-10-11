//
//  ViewController.swift
//  AR Drawing
//
//  Created by 张思槐 on 2017/10/9.
//  Copyright © 2017年 zhangsihuai. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    lazy var indicatorNode: SCNNode = {
        let node = SCNNode(geometry: SCNSphere(radius: 0.01))
        node.name = "indicator"
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        return node
        
    }()
    let configuration = ARWorldTrackingConfiguration()
    
    @IBOutlet weak var scnView: ARSCNView!
    @IBOutlet weak var drawButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scnView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        scnView.showsStatistics = true
        scnView.session.run(configuration)
        scnView.delegate = self
        //指示器
        scnView.scene.rootNode.addChildNode(indicatorNode)
    }
    
    @IBAction func resetButtonClick(_ sender: Any) {
        scnView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "sphere" {
                node.removeFromParentNode()
            }
        }
        
        //重新获取新的坐标
        scnView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
}

extension ViewController: ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        // The node provides the position and direction of a virtual camera, and the camera object provides rendering parameters such as field of view and focus.
        guard let pointOfView = renderer.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPositionOfCamera = orientation + location
        DispatchQueue.main.async {
            //isHighlighted属性只能用在UI线程
            if self.drawButton.isHighlighted{
                self.indicatorNode.position = currentPositionOfCamera
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.01))
                sphereNode.name = "sphere"
                sphereNode.position = currentPositionOfCamera
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
                self.scnView.scene.rootNode.addChildNode(sphereNode)
            }else{
                self.indicatorNode.position = currentPositionOfCamera
            }
        }
    }
}

func +(_ l: SCNVector3, r: SCNVector3) -> SCNVector3{
    return SCNVector3(l.x + r.x, l.y + r.y, l.z + r.z)
}







