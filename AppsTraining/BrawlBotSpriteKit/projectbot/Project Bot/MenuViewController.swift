//
//  MenuViewController.swift
//  Project Bot
//
//  Created by Tony Tresgots on 30/03/2020.
//  Copyright © 2020 Best Devs Evah. All rights reserved.
//

import UIKit
import SceneKit
import SceneKit.ModelIO
import AVFoundation

class MenuViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var backgroundMusic: AVAudioPlayer?
    
    var arrayRobot = [Robot(name: "Robotor", model: "robotBlue"), Robot(name: "Robbie The Destructor", model: "robotRed")]
    
    @IBOutlet weak var robotCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playBackgroundMusic()
    }
    
    func startRotation(node: SCNNode) {
        let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(0.01 * Double.pi), z: 0, duration: 0.1))
        node.runAction(rotate)
    }
    
    func playBackgroundMusic() {
        let path = Bundle.main.path(forResource: "intro.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            backgroundMusic = try AVAudioPlayer(contentsOf: url)
            backgroundMusic?.play()
            backgroundMusic?.numberOfLoops = -1
        } catch {
        
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayRobot.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = robotCollectionView.dequeueReusableCell(withReuseIdentifier: "robotCell", for: indexPath) as! RobotCell
        
        cell.robotNameLabel.text = arrayRobot[indexPath.row].name
        cell.layer.cornerRadius = 15
        
        let scene = SCNScene(named: "art.scnassets/objects.scn")!
        cell.sceneView.scene = scene
        cell.sceneView.backgroundColor = .clear
        
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        cell.sceneView.scene?.rootNode.camera = camera
        
        // add light the scene otherwise scene is dark
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        cell.sceneView.scene?.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        cell.sceneView.scene?.rootNode.addChildNode(ambientLightNode)
        
        guard let url = Bundle.main.url(forResource: "\(arrayRobot[indexPath.row].model)", withExtension: "OBJ", subdirectory: "art.scnassets")
             else { fatalError("Failed to find model file.") }

        let asset = MDLAsset(url:url)
        guard let object = asset.object(at: 0) as? MDLMesh
             else { fatalError("Failed to get mesh from asset.") }

        let newNode  = SCNNode(mdlObject: object)
        
        if arrayRobot[indexPath.row].model == "robotBlue" {
            for material in newNode.geometry!.materials {
                material.diffuse.contents = UIColor.blue
                material.metalness.contents = 1
                material.roughness.contents = UIColor.black
            }
        } else {
            newNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            newNode.geometry?.firstMaterial?.metalness.contents = 1
            newNode.geometry?.firstMaterial?.roughness.contents = UIColor.black
        }
        
        newNode.scale = SCNVector3Make(0.07, 0.07, 0.07)
        newNode.position = SCNVector3Make(0, -0.4, 0)
        
        cell.sceneView.autoenablesDefaultLighting = true
        
        self.startRotation(node: newNode)
        cell.sceneView.scene?.rootNode.addChildNode(newNode)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        backgroundMusic?.stop()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let gameViewController = storyboard.instantiateViewController(withIdentifier: "gameViewController") as! GameViewController
        gameViewController.modalPresentationStyle = .fullScreen
        self.present(gameViewController, animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
