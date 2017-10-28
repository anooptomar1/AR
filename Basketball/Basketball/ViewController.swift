//
//  ViewController.swift
//  Basketball
//
//  Created by 张思槐 on 2017/10/28.
//  Copyright © 2017年 zhangsihuai. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    var timer: Timer?
    var power: Float = 1.0
    var basketAdded = false
    
    let configuration = ARWorldTrackingConfiguration()
    
    @IBOutlet weak var scnView: ARSCNView!
    @IBOutlet weak var planeInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scnView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        configuration.planeDetection = .horizontal
        scnView.session.run(configuration)
        
        scnView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func showButtonTouchDown(_ sender: UIButton) {
        guard basketAdded else { return }
        timer = Timer(timeInterval: 0.05, repeats: true, block: { (_) in
            self.power = self.power + 1
        })
        RunLoop.current.add(timer!, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    @IBAction func showButtonTouchUp(_ sender: UIButton) {
        guard basketAdded else { return }
        timer?.invalidate()
        timer = nil
        shotBall()
        power = 1.0
    }
    
    func shotBall() {
        guard let camera = scnView.pointOfView else { return }
        let transform = camera.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let position = location + orientation
        let ball = SCNNode(geometry: SCNSphere(radius: 0.15))
        ball.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "ball")
        ball.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: ball))
        body.restitution = 0.2
        ball.physicsBody = body
        ball.name = "ball"
        let direction = SCNVector3(orientation.x * power, orientation.y * power, orientation.z * power)
        ball.physicsBody?.applyForce(direction, asImpulse: true)
        scnView.scene.rootNode.addChildNode(ball)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let scnView = gesture.view as? ARSCNView else { return }
        let location = gesture.location(in: scnView)
        let hitTestResult = scnView.hitTest(location, types: [.existingPlaneUsingExtent])
        if !hitTestResult.isEmpty {
            self.addBasket(hitTestResult.first!)
        }
    }
    
    func addBasket(_ result: ARHitTestResult) {
        guard !basketAdded else {
            print("Basket was already added!")
            return
        }
        let basketScene = SCNScene(named: "art.scnassets/Basket.scn")!
        let basketNode = basketScene.rootNode.childNode(withName: "basket", recursively: false)!
        let positionOfPlane = result.worldTransform.columns.3
        basketNode.position = SCNVector3(positionOfPlane.x, positionOfPlane.y, positionOfPlane.z)
        basketNode.physicsBody =
            SCNPhysicsBody(type: .static,
                           shape: SCNPhysicsShape(node: basketNode, options: [SCNPhysicsShape.Option.keepAsCompound : true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        self.scnView.scene.rootNode.addChildNode(basketNode)
        self.basketAdded = true
    }


}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let _  = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.planeInfoLabel.text = "Plane Deteceted!!!"
            self.planeInfoLabel.textColor = UIColor.green
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.planeInfoLabel.isHidden = true
        }
    }
}

func +(_ rhs: SCNVector3, _ lhs: SCNVector3) -> SCNVector3 {
    return SCNVector3(rhs.x + lhs.x, rhs.y + lhs.y, rhs.z + lhs.z)
}

