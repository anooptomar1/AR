//
//  ViewController.swift
//  PlaceItems
//
//  Created by 张思槐 on 2017/10/14.
//  Copyright © 2017年 zhangsihuai. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    let models = ["boxing", "cup", "table", "vase"]
    
    let configuration = ARWorldTrackingConfiguration()
    
    var selectedItem: String?
    
    @IBOutlet weak var scnView: ARSCNView!
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.allowsMultipleSelection = false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration.planeDetection = .horizontal
        scnView.session.run(configuration)
        scnView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        scnView.autoenablesDefaultLighting = true
        scnView.automaticallyUpdatesLighting = true
        
        registerGestureRecognizer()
    }
    
    func registerGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handlerTapGesture(_:)))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlerPinchGesture(_:)))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handlerLongPressGesture(_:)))
        scnView.addGestureRecognizer(tapGestureRecognizer)
        scnView.addGestureRecognizer(pinchGestureRecognizer)
        scnView.addGestureRecognizer(longPressGestureRecognizer)
    }

    @objc func handlerTapGesture(_ gesture: UITapGestureRecognizer) {
        let view = gesture.view as! ARSCNView
        let location = gesture.location(in: view)
        let hitTest = view.hitTest(location, types: [.estimatedHorizontalPlane, .existingPlaneUsingExtent])
        if !hitTest.isEmpty {
            addItem(hitTestResult: hitTest.first!)
        }
    }
    
    @objc func handlerPinchGesture(_ gesture: UIPinchGestureRecognizer) {
        let view = gesture.view as! ARSCNView
        let location = gesture.location(in: view)
        let hitTest = view.hitTest(location)
        if !hitTest.isEmpty {
            
            let result = hitTest.first!
            //获取操作物品的节点
            let node = result.node
            let scaleAction = SCNAction.scale(by: gesture.scale, duration: 0)
            node.runAction(scaleAction)
            gesture.scale = 1
        }
    }
    
    @objc func handlerLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let view = gesture.view as! ARSCNView
        let location = gesture.location(in: view)
        let hitTest = view.hitTest(location)
        if !hitTest.isEmpty {
            
            let result = hitTest.first!
            let node = result.node
            if gesture.state == .began{
                
                let action = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 1)
                let rotationAction = SCNAction.repeatForever(action)
                node.runAction(rotationAction)
                
            }else{
                node.removeAllActions()
            }
            
        }
    }
    
    func addItem(hitTestResult: ARHitTestResult) {
        guard let selectedItem = selectedItem else { return }
        let scene = SCNScene(named: "Models.scnassets/\(selectedItem).scn")!
        let node = scene.rootNode.childNode(withName: "\(selectedItem)", recursively: false)!
        let transform = hitTestResult.worldTransform
        let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        node.position = position
        scnView.scene.rootNode.addChildNode(node)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.identifier, for: indexPath) as! ItemCell
        cell.textLabel.text = models[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        selectedItem = models[indexPath.item]
        cell?.backgroundColor = UIColor.lightGray
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.groupTableViewBackground
    }
    
}

