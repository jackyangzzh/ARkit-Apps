//
//  ViewController.swift
//  Planets
//
//  Created by Zongzhen Yang on 5/24/19.
//  Copyright © 2019 JackYang. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints];
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true;
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let sun = SCNNode(geometry: SCNSphere(radius: 0.35))
        let earthParent = SCNNode()
        let venusParent = SCNNode()
        let moonParent = SCNNode()
        let mercuryParent = SCNNode()
        
        sun.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Sun Diffuse")
        sun.position = SCNVector3(0,0,-1)
        earthParent.position = SCNVector3(0,0,-1)
        venusParent.position = SCNVector3(0,0,-1)
        moonParent.position = SCNVector3(1.2,0,0)
        mercuryParent.position = SCNVector3(0,0,-1)
        self.sceneView.scene.rootNode.addChildNode(sun)
        self.sceneView.scene.rootNode.addChildNode(earthParent)
        self.sceneView.scene.rootNode.addChildNode(venusParent)
        self.sceneView.scene.rootNode.addChildNode(mercuryParent)
        
        let earth = planet(geometry: SCNSphere(radius: 0.2), diffuse: UIImage(named: "Earth Day")!, specular: UIImage(named: "Earth Specular")!, emission: UIImage(named: "Earth Emission")!, normal: UIImage(named: "Earth Normal")!, position: SCNVector3(1.2,0, 0))
        
        let venus = planet(geometry: SCNSphere(radius: 0.12), diffuse: UIImage(named: "Venus Surface")!, specular: nil, emission: UIImage(named: "Venus Atmosphere")!, normal: nil, position: SCNVector3(0.7,0,0))
        
        let earthMoon = planet(geometry: SCNSphere(radius: 0.05), diffuse: UIImage(named:"Moon")!, specular: nil, emission: nil, normal: nil, position: SCNVector3(0,0,-0.3))
        
        let mercury = planet(geometry: SCNSphere(radius: 0.06), diffuse: UIImage(named:"Mercury")!, specular: nil, emission: nil, normal: nil, position: SCNVector3(0.4,0,0))
        
        
        
        let earthParentRotation = Rotation(time: 14)
        
        let sunRotation = Rotation(time: 8)
        let venusParentRotation = Rotation(time: 10)
        let moonParentRotation = Rotation(time: 5)
        
        let mercuryRotation = Rotation(time: 3)
        let earthRotation = Rotation(time: 8)
        
        sun.runAction(sunRotation)
        earth.runAction(earthRotation)
        earthParent.runAction(earthParentRotation)
        venusParent.runAction(venusParentRotation)
        moonParent.runAction(moonParentRotation)
        mercuryParent.runAction(mercuryRotation)
        
        earthParent.addChildNode(earth)
        venusParent.addChildNode(venus)
        mercuryParent.addChildNode(mercury)
        earthParent.addChildNode(moonParent)
        earth.addChildNode(earthMoon)
        moonParent.addChildNode(earthMoon)
        
    }
    
    func planet(geometry: SCNGeometry, diffuse: UIImage, specular: UIImage?, emission: UIImage?, normal: UIImage?, position: SCNVector3) -> SCNNode{
        let planet = SCNNode(geometry: geometry)
        planet.geometry?.firstMaterial?.diffuse.contents = diffuse
        planet.geometry?.firstMaterial?.specular.contents = specular
        planet.geometry?.firstMaterial?.emission.contents = emission
        planet.geometry?.firstMaterial?.normal.contents = normal
        planet.position = position;
        return planet;
    }
    
    func Rotation(time: TimeInterval) -> SCNAction {
        let Rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: time)
        let foreverRotation = SCNAction.repeatForever(Rotation)
        return foreverRotation
    }
    

}

extension Int{
    var degreesToRadians: Double {return Double(self) * .pi/180}
}

