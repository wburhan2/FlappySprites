//
//  GameScene.swift
//  FlappySprites
//
//  Created by Wilson Burhan on 10/21/14.
//  Copyright (c) 2014 Wilson Burhan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var sprite = SKSpriteNode()
    var pipeUpTexture = SKTexture()
    var pipeDownTexture = SKTexture()
    var pipeMoveAndRemove = SKAction()
    
    let pipeGap = 150.0
    
    let spriteCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let pipeCategory: UInt32 = 1 << 2
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // Physics
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.0)
        
        // Sprites
        var spriteTexture = SKTexture(imageNamed: "sprite")
        spriteTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        sprite = SKSpriteNode(texture: spriteTexture)
        sprite.setScale(0.5)
        sprite.position = CGPointMake(self.frame.size.width * 0.35, self.frame.size.height * 0.6)
        
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.height / 2.0)
        sprite.physicsBody?.dynamic = true
        sprite.physicsBody?.allowsRotation = false
        
//        sprite.physicsBody?.categoryBitMask = spriteCategory
//        sprite.physicsBody?.collisionBitMask = worldCategory | pipeCategory
//        sprite.physicsBody?.contactTestBitMask = worldCategory | pipeCategory
        
        self.addChild(sprite)
        
        // Ground
        var groundTexture = SKTexture(imageNamed: "ground")
        
        var ground = SKSpriteNode(texture: groundTexture)
        ground.setScale(2.0)
        ground.position = CGPointMake(self.size.width / 2.0, ground.size.height / 2.0)
        self.addChild(ground)
        
        var groundNode = SKNode()
        groundNode.position = CGPointMake(0, groundTexture.size().height)
        groundNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.frame.size.width, height: groundTexture.size().height * 2.0))
        
        groundNode.physicsBody?.dynamic = false
        self.addChild(groundNode)
        
        // Pipes
        
        // Create the Pipes
        pipeUpTexture = SKTexture(imageNamed: "PipeUp")
        pipeDownTexture = SKTexture(imageNamed: "PipeDown")
        
        // Movement of pipes
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * pipeUpTexture.size().width)
        let movePipes = SKAction.moveByX(-distanceToMove, y: 0.0, duration: NSTimeInterval(0.01 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        pipeMoveAndRemove = SKAction.sequence([ movePipes, removePipes ])
        
        // Spawn pipes
        
        let spawn = SKAction.runBlock({() in self.spawnPipes()})
        let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([ spawn, delay ])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        
        self.runAction(spawnThenDelayForever)
    }
    
    func spawnPipes() {
        let pipePair = SKNode()
        pipePair.position = CGPointMake(self.frame.size.width + pipeUpTexture.size().width * 2.0, 0)
        pipePair.zPosition = -15
        
        let height = UInt32(self.frame.size.height / 4)
        let y = arc4random() % height + height
        
        let pipeDown = SKSpriteNode(texture: pipeDownTexture)
        pipeDown.setScale(2.0)
        pipeDown.position = CGPointMake(0.0, CGFloat(y) + pipeDown.size.height + CGFloat(pipeGap))
        
        pipeDown.physicsBody = SKPhysicsBody(rectangleOfSize: pipeDown.size)
        pipeDown.physicsBody?.dynamic = false
        pipePair.addChild(pipeDown)
        
        let pipeUp = SKSpriteNode(texture: pipeUpTexture)
        pipeUp.setScale(2.0)
        pipeUp.position = CGPointMake(0.0, CGFloat(y))
        
        pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
        pipeUp.physicsBody?.dynamic = false
        pipePair.addChild(pipeUp)
        
        pipePair.runAction(pipeMoveAndRemove)
        self.addChild(pipePair)
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            sprite.physicsBody?.velocity = CGVectorMake(0, 0)
            sprite.physicsBody?.applyImpulse(CGVectorMake(0, 25))
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
