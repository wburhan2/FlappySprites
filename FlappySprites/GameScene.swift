//
//  GameScene.swift
//  FlappySprites
//
//  Created by Wilson Burhan on 10/21/14.
//  Copyright (c) 2014 Wilson Burhan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var skyColor = SKColor()
    var sprite = SKSpriteNode()
    var pipeUpTexture = SKTexture()
    var pipeDownTexture = SKTexture()
    var pipeMoveAndRemove = SKAction()
    
    let pipeGap = 150.0
    
    let spriteCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let pipeCategory: UInt32 = 1 << 2
    
    var moving = SKNode()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.addChild(moving)
        
        // Physics
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.0)
        self.physicsWorld.contactDelegate = self
        
        // Sprites
        var spriteTexture = SKTexture(imageNamed: "sprite")
        spriteTexture.filteringMode = SKTextureFilteringMode.Nearest
        skyColor = SKColor(red: 113.0/255.0, green: 197.0/255.0, blue:207.0/255, alpha:1.0)
        self.backgroundColor = skyColor
        
        sprite = SKSpriteNode(texture: spriteTexture)
        sprite.setScale(0.5)
        sprite.position = CGPointMake(self.frame.size.width * 0.35, self.frame.size.height * 0.6)
        
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.height / 2.0)
        sprite.physicsBody?.dynamic = true
        sprite.physicsBody?.allowsRotation = false
        
        sprite.physicsBody?.categoryBitMask = spriteCategory
        sprite.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        sprite.physicsBody?.contactTestBitMask = worldCategory | pipeCategory
        
        moving.addChild(sprite)
        
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
        moving.addChild(groundNode)
        
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
        pipeDown.physicsBody?.categoryBitMask = pipeCategory
        pipeDown.physicsBody?.contactTestBitMask = spriteCategory
        pipePair.addChild(pipeDown)
        
        let pipeUp = SKSpriteNode(texture: pipeUpTexture)
        pipeUp.setScale(2.0)
        pipeUp.position = CGPointMake(0.0, CGFloat(y))
        
        pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
        pipeUp.physicsBody?.dynamic = false
        pipeUp.physicsBody?.categoryBitMask = pipeCategory
        pipeUp.physicsBody?.contactTestBitMask = spriteCategory
        pipePair.addChild(pipeUp)
        
        pipePair.runAction(pipeMoveAndRemove)
        moving.addChild(pipePair)
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        if (moving.speed > 0) {
            for touch: AnyObject in touches {
                let location = touch.locationInNode(self)
            
                sprite.physicsBody?.velocity = CGVectorMake(0, 0)
                sprite.physicsBody?.applyImpulse(CGVectorMake(0, 25))
            }
        }
    }
    
    func clamp (min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if (value > max) {
            return max
        } else if (value < min) {
            return min
        } else {
            return value
        }
        
    }
   
    //override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        //sprite.zRotation = self.clamp(-1, max: 0.5, value: sprite.physicsBody?.velocity.dx * (sprite.physicsBody?.velocity.dx < 0 ? 0.003 : 0.001))
    //}
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if (moving.speed > 0) {
            moving.speed = 0
            var turnBackgroundRed = SKAction.runBlock({() in self.setBackgroundRed()})
            var wait = SKAction.waitForDuration(0.05)
            var turnBackgroundWhite = SKAction.runBlock({() in self.setBackgroundWhite()})
            var turnBackgroundColorSky = SKAction.runBlock({() in self.setBackgroundSky()})
            var sequenceOfActions = SKAction.sequence([turnBackgroundRed, wait, turnBackgroundWhite, wait, turnBackgroundColorSky])
            var repeatSequence = SKAction.repeatAction(sequenceOfActions, count: 4)
            
            self.runAction(repeatSequence)
        }
    }
    
    func setBackgroundRed() {
        self.backgroundColor = UIColor.redColor()
    }
    
    func setBackgroundWhite() {
        self.backgroundColor = UIColor.whiteColor()
    }
    
    func setBackgroundSky() {
        self.backgroundColor = SKColor(red: 113.0/255.0, green: 197.0/255.0, blue:207.0/255, alpha:1.0)
    }
}
