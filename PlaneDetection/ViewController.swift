//
//  ViewController.swift
//  PlaneDetection
//
//  Created by macos on 19.01.2020.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    private var planeId: Int = 0
    
    let standardConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.isLightEstimationEnabled = true
        return configuration
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func runSession() {
        sceneView.delegate = self
        sceneView.session.run(standardConfiguration)
        #if DEBUG
        sceneView.showsStatistics = true
        sceneView.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints,
        ]
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        runSession()
    }
    
}

extension SCNNode {
    
    static func createPlaneNode(planeAnchor: ARPlaneAnchor, id: Int) -> SCNNode {
        let scenePlaneGeometry = ARSCNPlaneGeometry(device: MTLCreateSystemDefaultDevice()!)
        scenePlaneGeometry?.update(from: planeAnchor.geometry)
        let planeNode = SCNNode(geometry: scenePlaneGeometry)
        planeNode.name = "\(id)"
        switch planeAnchor.alignment {
        case .horizontal:
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.7)
        case .vertical:
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.7)
            
        @unknown default:
            fatalError()
        }
        return planeNode
    }
    
}


// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let planeNode = SCNNode.createPlaneNode(planeAnchor: planeAnchor, id: planeId)
        planeId += 1
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { child, _ in
            child.removeFromParentNode()
        }
        let planeNode = SCNNode.createPlaneNode(planeAnchor: planeAnchor, id: planeId)
        planeId += 1
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { child, _ in
            child.removeFromParentNode()
        }
    }
}
