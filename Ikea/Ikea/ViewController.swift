//
//  ViewController.swift
//  Ikea
//
//  Created by Zongzhen Yang on 5/26/19.
//  Copyright © 2019 JackYang. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ARSCNViewDelegate {

    @IBOutlet weak var planeDetected: UILabel!
    
    let itemArray: [String] = ["Doraemon", "Pokemon", "Jigglypuff", "Psyduck", "Pikachu", "Torchic"]
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var itemCollectionView: UICollectionView!
    let configuration = ARWorldTrackingConfiguration()
    var selectedItem: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.itemCollectionView.dataSource = self
        self.itemCollectionView.delegate = self
        self.sceneView.delegate = self
        self.registerGestureRecognizers()
        self.sceneView.autoenablesDefaultLighting = true
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func registerGestureRecognizers(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(rotate))
        longPressGestureRecognizer.minimumPressDuration = 0.3
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func pinch(sender:UIPinchGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let pinchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        
        if !hitTest.isEmpty {
            let result = hitTest.first!
            let node = result.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            node.runAction(pinchAction)
            sender.scale = 1.0
        }
    }
    
    @objc func tapped(sender: UITapGestureRecognizer){
        let scenceView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: scenceView)
        let hitTest = scenceView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty {
            self.addItem(hitTestResults: hitTest.first!)
            print("Touched a horizontal surface")
        } else {
            print("No match")
        }
    }
    
    @objc func rotate(sender: UILongPressGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let holdLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(holdLocation)
        if !hitTest.isEmpty {
            let result = hitTest.first!
            
            if sender.state == .began {
                let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 1)
                let forever = SCNAction.repeatForever(rotation)
                result.node.runAction(forever)
            }else if sender.state == .ended{
                result.node.removeAllActions()
                
            }
        }
        
    }
    
    func addItem(hitTestResults: ARHitTestResult){
        if let selectedItem = self.selectedItem{
            let scene = SCNScene(named: "Models.scnassets/\(selectedItem).scn")
            let node = (scene?.rootNode.childNode(withName: selectedItem, recursively: true))!
            node.look(at: SCNVector3(0,0,0))
            //node.localRotate(by: SCNVector4(0, 1, 0, 0))
            let transform = hitTestResults.worldTransform
            let thirdColumn = transform.columns.3
            
            node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
            if selectedItem == "Jigglypuff" {
                node.localRotate(by: SCNVector4(1,0,0,0))
            }
            self.sceneView.scene.rootNode.addChildNode(node)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! itemCell
        cell.itemLabel.text = self.itemArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        self.selectedItem = itemArray[indexPath.row]
        cell?.backgroundColor = UIColor.darkGray
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        DispatchQueue.main.async {
            self.planeDetected.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.planeDetected.isHidden = true
            }
        }
    }
    
    func centerPivot(for node: SCNNode){
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        node.pivot = SCNMatrix4MakeTranslation(min.x + (max.x - min.x)/2, min.y + (max.y - min.y)/2, min.z + (max.z - min.z)/2)
    }
}

extension Int {
    var degreesToRadians: Double {return Double(self) * .pi/180}
}
