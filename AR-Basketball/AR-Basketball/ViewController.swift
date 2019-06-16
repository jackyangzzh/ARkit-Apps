//
//  ViewController.swift
//  AR-Basketball
//
//  Created by Zongzhen Yang on 5/31/19.
//  Copyright © 2019 JackYang. All rights reserved.
//

import UIKit
import ARKit
import Each

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var planeDetected: UILabel!
    
    let configuration = ARWorldTrackingConfiguration()
    var power: Float = 1
    let timer = Each(0.05).seconds
    var basketedAdded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.cancelsTouchesInView = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.basketedAdded == true {
            timer.perform(closure: { () -> NextStep in
                self.power = self.power + 1
                return .continue
            })
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.basketedAdded == true{
            self.timer.stop()
            self.shootBall()
        }
        self.power = 1
    }
    
    func shootBall() {
        guard let pointOfView = self.sceneView.pointOfView else {return}
        self.removeBalls()
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let position = location + orientation
        let ball = SCNNode(geometry: SCNSphere(radius: 0.25))
        ball.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "ballTexture.png")
        ball.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: ball))
        ball.physicsBody = body
        ball.name = "Basketball"
        body.restitution = 0.2
        ball.physicsBody?.applyForce(SCNVector3(orientation.x * power, orientation.y * power, orientation.z * power), asImpulse: true )
        self.sceneView.scene.rootNode.addChildNode(ball)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])
        if !hitTestResult.isEmpty {
            self.addBasket(hitTestResult: hitTestResult.first!)
        }
        
    }

    func addBasket(hitTestResult: ARHitTestResult){
        if basketedAdded == false {
        let basketScene = SCNScene(named: "Model.scnassets/Basketball.scn")
        let basketNode = basketScene?.rootNode.childNode(withName: "Basket", recursively: false)
        let childNode = basketScene?.rootNode.childNode(withName: "backboard", recursively: true)
        childNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Model.scnassets/backboard.jpg")
        
        let positionOfPlane = hitTestResult.worldTransform.columns.3
        let xPosition = positionOfPlane.x
        let yPosition = positionOfPlane.y
        let zPosition = positionOfPlane.z
        basketNode?.position = SCNVector3(xPosition,yPosition,zPosition)
        basketNode?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: basketNode!, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        self.sceneView.scene.rootNode.addChildNode(basketNode!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {self.basketedAdded = true}
        }

    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        DispatchQueue.main.async {
            self.planeDetected.isHidden = false;
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            self.planeDetected.isHidden = true;
        }
    }
    
    func removeBalls() {
        self.sceneView.scene.rootNode.enumerateChildNodes{ (node, _) in
            if node.name == "Basketball" {
                node.removeFromParentNode()
            }}
    }
    
    deinit {
        self.timer.stop()
    }

}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

