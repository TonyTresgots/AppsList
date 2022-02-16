//
//  GameViewController.swift
//  Project Bot
//
//  Created by Yuri Spaziani on 24/03/2020.
//  Copyright © 2020 Best Devs Evah. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var imageResult: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(restartScene), name: Notification.Name("restartScene"), object: nil)

        startScene()
    }
    
    @objc func restartScene (notification: NSNotification) {
        startScene()
    }
    
    func startScene() {
        let scene = GameScene(size: CGSize(width: 1536, height: 2048))
        //        let scene = GameScene(size: self.view.bounds.size)
        scene.backgroundColor = UIColor(red:0.04, green:0.08, blue:0.18, alpha:1.00)
        scene.scaleMode = .aspectFill
        scene.gameViewController = self
        
        // Present the scene
        if let view = self.view as! SKView? {
            
            view.ignoresSiblingOrder = true
            view.presentScene(scene)
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
