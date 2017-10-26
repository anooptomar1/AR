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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let scnView = gesture.view as? ARSCNView else { return }
        let touchLocation = gesture.location(in: scnView)
        let hitTestResult = scnView.hitTest(touchLocation, types: [ .existingPlaneUsingExtent, .estimatedHorizontalPlane])
        if !hitTestResult.isEmpty {
            self.addPortal(hitTestResult.first!)
        }
    }
    
    func addPortal(_ result: ARHitTestResult) {
        let portalScene = SCNScene(named: "art.scnassets/Portal.scn")!
        let portalNode = portalScene.rootNode.childNode(withName: "Portal", recursively: false)!
        let transform = result.worldTransform
        let position = transform.columns.3
        portalNode.position = SCNVector3(position.x, position.y, position.z)
        self.scnView.scene.rootNode.addChildNode(portalNode)
        self.addPlane(nodeName: "top", portalNode: portalNode, imageName: "top.png")
        self.addPlane(nodeName: "bottom", portalNode: portalNode, imageName: "bottom.png")
        self.addWalls(nodeName: "back", portalNode: portalNode, imageName: "back.png")
        self.addWalls(nodeName: "left", portalNode: portalNode, imageName: "left.png")
        self.addWalls(nodeName: "right", portalNode: portalNode, imageName: "right.png")
        self.addWalls(nodeName: "frontL", portalNode: portalNode, imageName: "frontL.png")
        self.addWalls(nodeName: "frontR", portalNode: portalNode, imageName: "frontR.png")
    }
    
    func addWalls(nodeName: String, portalNode: SCNNode, imageName: String) {
        let wall = portalNode.childNode(withName: nodeName, recursively: false)!
        wall.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/\(imageName)")
        wall.renderingOrder = 200
        if let mask = wall.childNode(withName: "mask", recursively: false) {
            mask.geometry?.firstMaterial?.transparency = 0.000001
        }
    }
    
    func addPlane(nodeName: String, portalNode: SCNNode, imageName: String) {
        let plane = portalNode.childNode(withName: nodeName, recursively: false)
        plane?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/\(imageName)")
        plane?.renderingOrder = 200
    }
    


}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.sync {
            self.infoLabel.textColor = UIColor.green
            self.infoLabel.text = "Plane Detected!"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.infoLabel.isHidden = true
        }
    }
}

