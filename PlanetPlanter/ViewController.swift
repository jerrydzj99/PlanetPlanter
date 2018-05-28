//
//  ViewController.swift
//  PlanetPlanter
//
//  Created by Jerry Ding on 2018-05-27.
//  Copyright © 2018 Jerry Ding. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - ARSCNView Delegate Methods
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        node.replaceChildNode(node.childNodes.first!, with: planeNode)
    }
    
    //MARK: - Plane Rendering Methods
    
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        
        planeNode.geometry = plane
        return planeNode
        
    }
    
    //MARK: - Planet Rendering Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                addPlanet(atLocation: hitResult)
            }
            
        }
        
    }
    
    func addPlanet(atLocation location: ARHitTestResult) {
        
        let planet = SCNSphere(radius: 0.005)
        let planetMaterial = SCNMaterial()
        planetMaterial.diffuse.contents = UIImage(named: "art.scnassets/8k_moon.jpg")
        planet.materials = [planetMaterial]
        let planetNode = SCNNode()
        planetNode.position = SCNVector3(
            x: location.worldTransform.columns.3.x,
            y: location.worldTransform.columns.3.y + Float(planet.radius),
            z: location.worldTransform.columns.3.z
        )
        planetNode.geometry = planet
        sceneView.scene.rootNode.addChildNode(planetNode)
        
        rotate(planetWithNode: planetNode)
        grow(planetWithNode: planetNode)
        
        let core = SCNSphere(radius: 0.0025)
        let coreMaterial = SCNMaterial()
        coreMaterial.diffuse.contents = UIColor.brown
        core.materials = [coreMaterial]
        let coreNode = SCNNode()
        coreNode.position = planetNode.position
        coreNode.geometry = core
        sceneView.scene.rootNode.addChildNode(coreNode)
        
        rotate(planetWithNode: coreNode)
        grow(planetWithNode: coreNode)
        
    }
    
    func rotate(planetWithNode planet: SCNNode) {
        
        planet.runAction(SCNAction.repeatForever(SCNAction.rotateBy(
            x: 0,
            y: CGFloat(Float.pi),
            z: 0,
            duration: 3
        )))
        
    }
    
    func grow(planetWithNode planet: SCNNode) {
        
        planet.runAction(SCNAction.repeatForever(SCNAction.scale(by: 1.1, duration: 2)))
        
    }
    
}
