//
//  GameScene.swift
//  Project 11
//
//  Created by Deonte on 7/18/19.
//  Copyright © 2019 Deonte. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ballNodes: SKNode!
    var boxNodes: SKNode!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
                
                scoreLabel.alpha = 0
                ballCountLabel.alpha = 0
            } else {
                editLabel.text = "Edit"
                
                scoreLabel.alpha = 1
                ballCountLabel.alpha = 1
            }
        }
    }
    
    var ballCountLabel: SKLabelNode!
    var numberOfBalls = 5 {
        didSet {
            ballCountLabel.text = "Balls: \(numberOfBalls)"
            // If the user creates barrier not allowing balls to get points this will let them restart the game.
            if numberOfBalls == 0 {
                delayAlert()
            }
        }
    }
    
    // Challenge 1: Randomize Ball Colors
    let ballColorArray = ["ballBlue", "ballRed","ballCyan","ballGreen","ballYellow","ballPurple","ballGrey"]
    
    override func didMove(to view: SKView) {
        
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        ballCountLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballCountLabel.text = "Balls: 5"
        ballCountLabel.position = CGPoint(x: 512, y: 700)
        addChild(ballCountLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            
            if editingMode {
                
                // Create a box when in editing mode
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                ballNodes = box
                addChild(box)
                
            } else {
                // Creates new ball Nodes untill the number of balls variable is == 0
                if numberOfBalls != 0 {
                    numberOfBalls -= 1
                    
                    let ball = SKSpriteNode(imageNamed: ballColorArray.randomElement() ?? "ballRed")
                    // Challenge 2: Force the y position of the balls so they are near the top of the screen.
                    ball.position = CGPoint(x: location.x, y: 650)
                    ballNodes = ball
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    ball.physicsBody?.restitution = 0.4
                    ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                    ball.name = "ball"
                    addChild(ball)
                }
                
            }
            
        }
        
    }
    
    @objc func alertUser() {
        let alertController = UIAlertController(title: "Ran Out Of Balls", message: "Would you like to restart?", preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart", style: .default) { (_) in
            print("Something Happen")
            self.numberOfBalls = 5
            self.score = 0
            self.collisionNumber = 0
            self.removeAllChildren()
            self.didMove(to: self.view!)
        }
        alertController.addAction(restartAction)
        view?.window?.rootViewController?.present(alertController, animated: true)
    }
    
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        bouncer.zPosition = 2
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
            
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    
    var collisionNumber = 0 {
        // Checks for number of collisions to equal to 5. Has potential to fail if user creates stacks of boxes that do not allow for balls to come in contact with slots.
        didSet {
            if collisionNumber == 5 {
                //alertUser()
            }
        }
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            collisionNumber += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
            collisionNumber += 1
        }
        
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
    }
    
    // All Code below creates an animation that sends the zooms in on the players last ball. Animation needs some work but the gist of is there.
    
    let cam = SKCameraNode()
    
    func zoomIn() {
        
        camera = cam
        cam.position.y = ballNodes.position.y
        cam.position.x = ballNodes.position.x
        cam.xScale = 0.2
        cam.yScale = 0.2
        
        let zoomInAction = SKAction.scale(to: 1 , duration: 3)
        cam.run(zoomInAction)
    }
    
    func zoomOut() {
        camera = cam
        cam.xScale = 1
        cam.yScale = 1
        cam.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func delayAlert() {
        // Checks if the number of balls are equal to zero then alerts user with a delay to let any animation complete.
        if numberOfBalls == 0 {
            perform(#selector(alertUser), with: nil, afterDelay: 3)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if numberOfBalls == 0 {
            zoomIn()
        } else if numberOfBalls == 5 {
            zoomOut()
        }
    }

}
