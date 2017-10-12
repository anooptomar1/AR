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
        
        
        
        let sunNode = createSunNode()
        sunNode.position = SCNVector3(0, 0, -1)
        scnView.scene.rootNode.addChildNode(sunNode)
        
        let earthParent = SCNNode()
        let venusParent = SCNNode()
        earthParent.position = sunNode.position
        venusParent.position = sunNode.position
        scnView.scene.rootNode.addChildNode(earthParent)
        scnView.scene.rootNode.addChildNode(venusParent)
        
        let venusNode = createVenusNode()
        venusNode.position = SCNVector3(0.75, 0, 0)
        venusParent.addChildNode(venusNode)
        
        let earthNode = createEarthNode()
        earthNode.position = SCNVector3(0, 0, 1.2)
        earthParent.addChildNode(earthNode)
        
        let moonParent = SCNNode()
        earthParent.addChildNode(moonParent)
        moonParent.position = earthNode.position
        
        let moonNode = createMoonNode()
        moonNode.position = SCNVector3(0, 0, 0.35)
        moonParent.addChildNode(moonNode)
        
        //地球与金星的公转不同

        let earthParentAction = rotation(time: 10)
        let venusParentAction = rotation(time: 8)
        let moonParentAction = rotation(time: 5)
        
        earthParent.runAction(earthParentAction)
        venusParent.runAction(venusParentAction)
        moonParent.runAction(moonParentAction)
    }
    
 
    
    func createSunNode() -> SCNNode {
        let sunNode = planet(geometry: SCNSphere(radius: 0.35),
                         diffuse: UIImage(named: "sun"),
                         emission: nil,
                         specular: nil,
                         normal: nil)
        
        let action = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 30)
        let rotaionAction = SCNAction.repeatForever(action)
        sunNode.runAction(rotaionAction)
    
        return sunNode
    }
    
    func createEarthNode() -> SCNNode {
        let earthNode = planet(geometry: SCNSphere(radius: 0.2),
                               diffuse: UIImage(named: "earth_daymap"),
                               emission: UIImage(named: "earth_clouds"),
                               specular: UIImage(named: "earth_specular"),
                               normal: UIImage(named: "earth_normal"))
        
        
        //自转动作
        let action = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 8)
        let rotaionAction = SCNAction.repeatForever(action)
        earthNode.runAction(rotaionAction)
        
        return earthNode
    }
    
    func createVenusNode() -> SCNNode {
        let venusNode = planet(geometry: SCNSphere(radius: 0.1),
                      diffuse: UIImage(named: "venus_surface"),
                      emission: UIImage(named: "venus_atmosphere"),
                      specular: nil,
                      normal: nil)
        
        let action = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 5)
        let rotaionAction = SCNAction.repeatForever(action)
        venusNode.runAction(rotaionAction)
        
        return venusNode
    }
    
    func createMoonNode() -> SCNNode {
        let moonNode = planet(geometry: SCNSphere(radius: 0.05),
                              diffuse: UIImage(named: "moon"),
                              emission: nil,
                              specular: nil,
                              normal: nil)
        return moonNode
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController {
    func planet(geometry: SCNGeometry, diffuse: UIImage?, emission: UIImage?, specular: UIImage?, normal: UIImage?) -> SCNNode {
        let node = SCNNode(geometry: geometry)
        //贴图
        node.geometry?.firstMaterial?.diffuse.contents = diffuse
        node.geometry?.firstMaterial?.emission.contents = emission
        node.geometry?.firstMaterial?.specular.contents = specular
        node.geometry?.firstMaterial?.normal.contents = normal
        
        return node
    }
    
    func rotation(time: TimeInterval) -> SCNAction {
        let rotation = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: time)
        let action = SCNAction.repeatForever(rotation)
        return action
    }
}




