//
//  ViewController.swift
//  Whack A Jellyfish
//
//  Created by Benjamin Salter on 8/24/20.
//  Copyright © 2020 Benjamin Salter. All rights reserved.
//

import UIKit
import ARKit
import Each

class ViewController: UIViewController {
    var timer = Each(1).seconds
    var countdown = 10
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
        
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    @IBAction func playPressed(_ sender: UIButton) {
        self.setTimer()
        addNode()
        play.isEnabled = false
    }
    
    @IBAction func resetPressed(_ sender: UIButton) {
        timer.stop()
        restoreTimer()
        play.isEnabled = true
        timerLabel.text = "Let's Play"
        
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
    }
    
    func addNode() {
        let jellyfishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        if let jellyfishNode = jellyfishScene?.rootNode.childNode(withName: "Jellyfish", recursively: false) {
            jellyfishNode.position = SCNVector3(randomNumbers(firstNum: -1, secondNum: 1), randomNumbers(firstNum: -0.5, secondNum: 0.5), randomNumbers(firstNum: -1, secondNum: 1))
            self.sceneView.scene.rootNode.addChildNode(jellyfishNode)
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        if !hitTest.isEmpty && countdown > 0 {
            let results = hitTest.first!
            let foundNode = results.node
            if foundNode.animationKeys.isEmpty {
                SCNTransaction.begin()
                self.animateNode(node: foundNode)
                SCNTransaction.completionBlock = {
                    foundNode.removeFromParentNode()
                    self.addNode()
                    self.restoreTimer()
                }
                SCNTransaction.commit()
            }
        }
    }
    
    func animateNode(node: SCNNode) {
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position
        spin.toValue = SCNVector3(node.presentation.position.x - 0.2, node.presentation.position.y - 0.2, node.presentation.position.z - 0.2)
        spin.duration = 0.07
        spin.autoreverses = true
        spin.repeatCount = 5
        node.addAnimation(spin, forKey: "position")
    }
    
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func setTimer() {
        self.timer.perform { () -> NextStep in
            self.countdown -= 1
            self.timerLabel.text = String(self.countdown)
            if self.countdown == 0 {
                self.timerLabel.text = "You Lose!"
                return .stop
            }
            return .continue
        }
    }
    
    func restoreTimer() {
        countdown = 10
        timerLabel.text = String(countdown)
    }

}

