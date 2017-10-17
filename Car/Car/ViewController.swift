//
//  ViewController.swift
//  Car
//
//  Created by 张思槐 on 2017/10/17.
//  Copyright © 2017年 zhangsihuai. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    let configuration = ARWorldTrackingConfiguration()
    
    var vehicle = SCNPhysicsVehicle()
    
    @IBOutlet weak var scnView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration.planeDetection = .horizontal
        scnView.session.run(configuration)
        scnView.delegate = self
        scnView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
    }
    
    @IBAction func addButtonClick(_ sender: UIButton) {
        addCar()
    }
    
    func addCar() {
        guard let camere = scnView.pointOfView else { return }
        let transform = camere.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPosition = orientation + location
        let carScene = SCNScene(named: "Car.scn")!
        let carNode = carScene.rootNode.childNode(withName: "Car", recursively: false)!
        var wheels: [SCNPhysicsVehicleWheel] = []
        for i in 1...4{
            let node = carNode.childNode(withName: "wheel\(i)", recursively: false)!
            let wheel = SCNPhysicsVehicleWheel(node: node)
            wheels.append(wheel)
        }
        
        let carBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: carNode, options: [SCNPhysicsShape.Option.keepAsCompound : true]))
        
        self.vehicle = SCNPhysicsVehicle(chassisBody: carBody, wheels: wheels)
        self.scnView.scene.physicsWorld.addBehavior(vehicle)
        
        carNode.position = currentPosition
        self.scnView.scene.rootNode.addChildNode(carNode)
        
    }
    
    func createPlane(by anchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        plane.firstMaterial?.diffuse.contents = UIImage(named: "concrete")
        plane.firstMaterial?.isDoubleSided = true
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        //创建物理效果
        //static: 不受重力影响，但是会与其它的物体碰撞
        let staticBody = SCNPhysicsBody.static()
        planeNode.physicsBody = staticBody
        return planeNode
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            let planeNode = createPlane(by: planeAnchor)
            node.addChildNode(planeNode)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            node.enumerateChildNodes({ (node, _) in
                node.removeFromParentNode()
            })
            let planeNode = createPlane(by: planeAnchor)
            node.addChildNode(planeNode)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let _ = anchor as? ARPlaneAnchor {
            node.enumerateChildNodes({ (node, _) in
                node.removeFromParentNode()
            })
        }
    }
}

private func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
}

