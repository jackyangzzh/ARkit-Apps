//
//  ViewController.swift
//  AR-Shooter
//
//  Created by Zongzhen Yang on 6/1/19.
//  Copyright © 2019 JackYang. All rights reserved.
//

import UIKit
import ARKit
import Each

enum BitMapCategory: Int {
    case bullet = 2
    case target = 3
}

class ViewController: UIViewController, SCNPhysicsContactDelegate{

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    var power: Float = 50
    var target: SCNNode?
    var score = 0
    var timer = Each(1).seconds
    var countDown = 6
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var play: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(gestureRecognizer)
        self.sceneView.scene.physicsWorld.contactDelegate = self
    }

    @objc func handleTap(sender: UITapGestureRecognizer){
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let pointOfView = sceneView.pointOfView else {return}
        
        if countDown > 0 {
            let transform = pointOfView.transform
            let orientation = SCNVector3(-transform.m31,-transform.m32, -transform.m33)
            let location = SCNVector3(transform.m41, transform.m42, transform.m43)
            let position = orientation + location
            
            let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
            bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            bullet.position = position
            
            let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet, options: nil))
            body.isAffectedByGravity = false
            bullet.physicsBody = body
            bullet.physicsBody?.applyForce(SCNVector3(orientation.x * power, orientation.y * power, orientation.z * power), asImpulse: true)
            bullet.physicsBody?.categoryBitMask = BitMapCategory.bullet.rawValue
            bullet.physicsBody?.contactTestBitMask = BitMapCategory.target.rawValue
            
            self.sceneView.scene.rootNode.addChildNode(bullet)
            
            bullet.runAction(SCNAction.sequence([SCNAction.wait(duration: 2.0), SCNAction.removeFromParentNode()]))
            
        }
        
    }

    
    @IBAction func play(_ sender: Any) {
        self.setTimer()
        self.addEgg()
        self.play.isEnabled = false
        self.score = 0
        DispatchQueue.main.async {
            self.scoreLabel.text = "\(self.score)"
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        self.timer.stop()
        self.restoreTimer()
        self.play.isEnabled = true
        self.score = 0
        DispatchQueue.main.async {
            self.scoreLabel.text = "\(self.score)"
        }
        sceneView.scene.rootNode.enumerateChildNodes{ (node, _) in node.removeFromParentNode()}
    }
    
    
    
    func addEgg() {
        let eggScene = SCNScene(named: "Media.scnassets/jack.scn")
        let eggNode = (eggScene?.rootNode.childNode(withName: "body", recursively: true))!
        let xPos = Float(randomNumbers(firstNum: 18, secondNum: -18))
        let yPos = Float(randomNumbers(firstNum: 18, secondNum: -18))
        let zPos = Float(randomNumbers(firstNum: -25, secondNum: -50))
        eggNode.position = SCNVector3(xPos,yPos,zPos)
        eggNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: eggNode, options: nil))
        eggNode.physicsBody?.categoryBitMask = BitMapCategory.target.rawValue
        eggNode.physicsBody?.contactTestBitMask = BitMapCategory.bullet.rawValue
        self.sceneView.scene.rootNode.addChildNode(eggNode)
        print("Added!")
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        if nodeA.physicsBody?.categoryBitMask == BitMapCategory.target.rawValue {
            self.target = nodeA
        } else if nodeB.physicsBody?.categoryBitMask == BitMapCategory.target.rawValue {
            self.target = nodeB
        }
        let confetti = SCNParticleSystem(named: "Media.scnassets/shotAnimation.scnp", inDirectory: nil)
        confetti?.loops = false
        confetti?.particleLifeSpan = 4
        confetti?.emitterShape = target?.geometry
        let confettiNode = SCNNode()
        confettiNode.addParticleSystem(confetti!)
        confettiNode.position = contact.contactPoint
        confettiNode.scale = SCNVector3(10,10,10)
        self.sceneView.scene.rootNode.addChildNode(confettiNode)
        target?.removeFromParentNode()
        
        self.addEgg()
        self.restoreTimer()
        self.score += 1
        DispatchQueue.main.async {
            self.scoreLabel.text = "\(self.score)"
        }
        
    }
    
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func setTimer() {
        self.timer.perform { () -> NextStep in
            self.countDown -= 1
            DispatchQueue.main.async {
                self.timerLabel.text = "Time Left: " + String(self.countDown)
            }
            if self.countDown == 0 {
                self.timerLabel.text = "Game Over :<"
                return .stop
            }
            return .continue
        }
    }
    
    func restoreTimer() {
        self.countDown = 6
        DispatchQueue.main.async {
            self.timerLabel.text = "Time Left: " + String(self.countDown)
        }
        
    }
    
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
