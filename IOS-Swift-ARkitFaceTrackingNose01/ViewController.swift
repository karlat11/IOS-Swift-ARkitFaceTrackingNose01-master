//
//  ViewController.swift
//  IOS-Swift-ARkitFaceTrackingNose01
//
//  Created by Pooya on 2018-11-27.
//  Copyright © 2018 Soonin. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var label: UILabel!
    
    
    let noseOptions = ["nose1", "nose2", "nose3", "nose4"]
    let features = ["nose"]
    var featureIndices = [[1]]
    let textOptions = ["Text 1 Litwo ojczyno moja", "Text 2 Ty jestes jak zdrowie", "Text 3 Ile Cie trzeba cenic", "Text 4 Ten tylko sie dowie kto Cie stracil"]
    var textIdx = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        self.text.text = textOptions.first!
        self.label.text = textOptions.first!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuratio = ARFaceTrackingConfiguration()
        
        sceneView.session.run(configuratio)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        let results = sceneView.hitTest(location, options: nil)
        print(results)
        if let result = results.first,
            let node = result.node as? FaceNode {
            print(node)
            node.next()
            updateText()
        }
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print(self.noseOptions.randomElement()!)
            print(sceneView)
            print(sceneView.node)
            updateText()
            
//            print(self.nod)
////            let child = self.
//            FaceNode
//            let child = node.childNode(withName: feature, recursively: false) as? FaceNode
//            child?.next()
            
        }
        
    }
    
    func updateOnMotion(for node: SCNNode, using anchor: ARFaceAnchor) {
        for (feature, _) in zip(features, featureIndices) {
            let child = node.childNode(withName: feature, recursively: false) as? FaceNode
            child?.next()
        }
    }
    
    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
//        print(featureIndices)
        for (feature, indices) in zip(features, featureIndices) {
            let child = node.childNode(withName: feature, recursively: false) as? FaceNode
            let vertices = indices.map { anchor.geometry.vertices[$0] }
            child?.updatePosition(for: vertices)
        }
    }
    
    func updateText() {
//        self.textid = (index + 1) % options.count
        self.textIdx = (textIdx + 1) % self.textOptions.count
        self.label.text = self.textOptions[textIdx]
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let device: MTLDevice!
        device = MTLCreateSystemDefaultDevice()
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            return nil
        }
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)
//                node.geometry?.firstMaterial?.fillMode = .lines
        node.geometry?.firstMaterial?.transparency = 0.0
        
        let noseNode = FaceNode(with: noseOptions)
        noseNode.name = "nose"
        node.addChildNode(noseNode)
        
//        print(noseNode)
//        print(node)
        
        updateFeatures(for: node, using: faceAnchor)
        
        return node
    }
    
    func renderer(
        _ renderer: SCNSceneRenderer,
        didUpdate node: SCNNode,
        for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                return
        }
        
        faceGeometry.update(from: faceAnchor.geometry)
        updateFeatures(for: node, using: faceAnchor)
    }
    
    
}

