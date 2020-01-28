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
    
    public var FNodeInstance: SCNNode!
    
    let noseOptions = ["moustache1", "", "moustache2"]
    let hatOptions = ["hat1", "", "hat2"]
    let features = ["nose", "hat"]
    let featuresHat = ["hat"]
    var featureIndices = [[0], [13]]
    let textOptions = ["Jozef Pilsudzki, the First Marshal of Poland rejected the offer of presidency.", "Heinrich Himmler was searching for Holy Grail to help the Nazi army win the war.", "Stalin had multiple dopplegangers who to proctect himself."]
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
//            public var node = node
            print("node", node)
            node.next()
            updateText()
            print("self", self)
        }
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            updateText()
            print("FNodeInstance", FNodeInstance.childNodes.first!)
            let node = FNodeInstance.childNodes.first! as? FaceNode
            node?.next()
        }
        
    }
    
    func updateOnMotion(for node: SCNNode, using anchor: ARFaceAnchor) {
        for (feature, _) in zip(features, featureIndices) {
            let child = node.childNode(withName: feature, recursively: false) as? FaceNode
            child?.next()
        }
    }
    
    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
        for (feature, indices) in zip(features, featureIndices) {
            let child = node.childNode(withName: feature, recursively: false) as? FaceNode
            let vertices = indices.map { anchor.geometry.vertices[$0] }
            child?.updatePosition(for: vertices)
        }
    }
    
    func updateText() {
        self.textIdx = (textIdx + 1) % self.textOptions.count
        self.label.text = self.textOptions[textIdx]
    }
    
    func updateTexture() {
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
        
        FNodeInstance = node
        
        updateFeatures(for: node, using: faceAnchor)
        
        return FNodeInstance
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

