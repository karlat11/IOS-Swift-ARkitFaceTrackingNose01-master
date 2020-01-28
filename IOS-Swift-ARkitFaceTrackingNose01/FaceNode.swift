//
//  FaceNode.swift
//  IOS-Swift-ARkitFaceTrackingNose01
//
//  Created by Pooya on 2018-11-27.
//  Copyright © 2018 Soonin. All rights reserved.
//

import SceneKit

public class FaceNode: SCNNode {
    
    var options: [String]
//    var textOptions: [String]
    var index = 0
//    var textIdx = 0
    
//    @IBOutlet weak var text: UITextView!
    
    init(with options: [String], width: CGFloat = 0.06, height: CGFloat = 0.06) {
        self.options = options
//        self.textOptions = textOptions
        
        super.init()
        
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents =  UIImage(named: options.first!)
        plane.firstMaterial?.isDoubleSided = true
        
        geometry = plane
        
//        print("self", self)
        
//        text.text = textOptions.first!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct globalVariables {
        static var FNode = self
    }
}

// MARK: - Custom functions

extension FaceNode {
    
    func updatePosition(for vectors: [vector_float3]) {
        let newPos = vectors.reduce(vector_float3(), +) / Float(vectors.count)
        position = SCNVector3(newPos)
    }
    
    public func next() {
        index = (index + 1) % options.count
//        textIdx = (textIdx + 1) % textOptions.count
        
        if let plane = geometry as? SCNPlane {
            if (options[index] == "") {
                print("options !!!", options[index])
                plane.firstMaterial?.transparency = 0.0
            } else {
                plane.firstMaterial?.transparency = 1.0
            }
            plane.firstMaterial?.diffuse.contents = UIImage(named: options[index])
            plane.firstMaterial?.isDoubleSided = true
        }
        
//        text.text = textOptions[textIdx]
    }
}

