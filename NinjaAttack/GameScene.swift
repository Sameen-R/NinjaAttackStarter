/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SpriteKit

struct PhysicsCategory{
  static let none:        UInt32 = 0
  static let all:         UInt32 = UInt32.max
  static let monster:     UInt32 = 0b1
  static let projectile:  UInt32 = 0b10
  static let dragon:      UInt32 = 0b100
  static let megaMonster: UInt32 = 0b1000
}

func +(left: CGPoint, right: CGPoint) -> CGPoint{
  return CGPoint(x: left.x+right.x, y: left.y+right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint{
  return CGPoint(x: left.x-right.x, y: left.y-right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint{
  return CGPoint(x: point.x*scalar, y: point.y*scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint{
  return CGPoint(x: point.x/scalar, y: point.y/scalar)
}

#if !(arch(x86_64) || arch(arm64))
  func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
  }
#endif

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x+y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}

let defaults = UserDefaults.standard

class GameScene: SKScene {
  let player = SKSpriteNode(imageNamed: "player")
  let homeButton = SKSpriteNode()
  let homeButtonLabel = SKLabelNode(fontNamed: "BanglaSangamMN-Bold")
  var label = SKLabelNode()
  var score = SKLabelNode()
  var highScoreLabal = SKLabelNode()
  var monstersDestroyed = 0
  var points = 0
  var highScore = 0
//  let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//  var fileURL:URL {
//    URL(fileURLWithPath: "HIGH_SCORE", relativeTo: directoryURL).appendingPathExtension("txt")
//  }
  
  
  override func didMove(to view: SKView){
    do{
      try highScore = defaults.integer(forKey: "high_score")
    }catch{
      defaults.set(0, forKey: "high_score")
    }
    
    homeButton.position = CGPoint(x: size.width*0.8, y: size.height*0.9)
    homeButton.color = SKColor.green
    homeButton.size = CGSize(width: CGFloat(100), height: CGFloat(50))
    homeButton.isUserInteractionEnabled = true
    addChild(homeButton)
    
    homeButtonLabel.text = "home screen"
    homeButtonLabel.fontSize = 15
    homeButtonLabel.fontColor = SKColor.black
    homeButtonLabel.position = homeButton.position
    addChild(homeButtonLabel)
    
    backgroundColor = SKColor.white
    player.position = CGPoint(x: size.width*0.1, y: size.height*0.5)
    addChild(player)
    
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    
    label.text = "Kills: "+String(monstersDestroyed)
    label.position = CGPoint(x: size.width*0.1, y: size.height*0.9)
    label.fontSize = 20
    label.fontColor = SKColor.red
    addChild(label)
    
    score.text = "Score: "+String(points)
    score.position = CGPoint(x: size.width*0.3, y: size.height*0.9)
    score.fontSize = 20
    score.fontColor = SKColor.blue
    addChild(score)
    
    highScoreLabal.text = "High Score: "+String(highScore)
    highScoreLabal.position = CGPoint(x: size.width*0.5, y: size.height*0.9)
    highScoreLabal.fontSize = 20
    highScoreLabal.fontColor = SKColor.blue
    addChild(highScoreLabal)
    
    run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.run(addMegaMonster),
        SKAction.run(addDragon),
        SKAction.run(addMonster),
        SKAction.wait(forDuration: 1.0)
      ])
    ))
    
    let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
    backgroundMusic.autoplayLooped = true
    addChild(backgroundMusic)
  }
  
  func getHighScore() -> Int{
    highScore = (points>defaults.integer(forKey: "high_score")) ? points : defaults.integer(forKey: "high_score")
    return highScore
  }
  
  func writeHighScore(score: Int){
    defaults.set(score, forKey: "high_score")
  }
 
  func resetHighScore(){
    defaults.set(0, forKey: "high_score")
  }
  
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }
  
  func random(min: CGFloat, max: CGFloat) -> CGFloat{
    return random()*(max-min)+min
  }
  
  func addMonster() {
    let monster = SKSpriteNode(imageNamed: "monster")
    let actualY = random(min: monster.size.height/2, max: size.height*0.8-monster.size.height/2)
    monster.position = CGPoint(x: size.width+monster.size.width/2, y: actualY)
    addChild(monster)
    
    monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
    monster.physicsBody?.isDynamic = true
    monster.physicsBody?.categoryBitMask = PhysicsCategory.monster
    monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
    monster.physicsBody?.collisionBitMask = PhysicsCategory.none
    
    let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
    let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
    let actionMoveDone = SKAction.removeFromParent()
    let loseAction = SKAction.run() { [weak self] in
      guard let `self` = self else {return}
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      let gameOverScene = GameOverScene(size: self.size, won: false)
      self.view?.presentScene(gameOverScene, transition: reveal)
    }
    monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
  }
  
  func addMegaMonster() {
    if points>=50 {
      if random() < 0.6 {addOneMegaMonster(duration: 0.3)}
    }else if points>=25 {
      if random() < 0.4 {addOneMegaMonster(duration: 0.45)}
    }else{
      if random() < 0.2 {addOneMegaMonster(duration: 0.6)}
    }
  }
  
  func addOneMegaMonster(duration: Float) {
    let monster = RobustNode(imageNamed: "monsterV2")
    let actualY = random(min: monster.size.height/2, max: size.height*0.8-monster.size.height/2)
    monster.position = CGPoint(x: size.width+monster.size.width/2, y: actualY)
    addChild(monster)
    
    monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
    monster.physicsBody?.isDynamic = true
    monster.physicsBody?.categoryBitMask = PhysicsCategory.megaMonster
    monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile | PhysicsCategory.monster
    monster.physicsBody?.collisionBitMask = PhysicsCategory.none
    
    let actualDuration = CGFloat(6.0)
    let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
    let actionMoveDone = SKAction.removeFromParent()
    let loseAction = SKAction.run() { [weak self] in
      guard let `self` = self else {return}
      let reveal = SKTransition.flipHorizontal(withDuration: TimeInterval(duration))
      let gameOverScene = GameOverScene(size: self.size, won: false)
      self.view?.presentScene(gameOverScene, transition: reveal)
    }
    monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
  }
  
  func addDragon(){
    if random() < CGFloat(0.2){
      let dragon = SKSpriteNode(imageNamed: "dragon")
      let actualY = random(min: dragon.size.height/2, max: size.height*0.8-dragon.size.height/2)
      dragon.position = CGPoint(x: size.width+dragon.size.width/2, y: actualY)
      addChild(dragon)
      
      dragon.physicsBody = SKPhysicsBody(rectangleOf: dragon.size)
      dragon.physicsBody?.isDynamic = true
      dragon.physicsBody?.categoryBitMask = PhysicsCategory.dragon
      dragon.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
      dragon.physicsBody?.collisionBitMask = PhysicsCategory.none
      
      let actualDuration = random(min: CGFloat(1.0), max: CGFloat(2.0))
      let actionMove = SKAction.move(to: CGPoint(x: -dragon.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
      let actionDone = SKAction.removeFromParent()
      dragon.run(SKAction.sequence([actionMove, actionDone]))
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches{
      let location = touch.location(in: self)
      if homeButton.contains(location){
        let scene = GameStartScene(size: self.size)
        view?.presentScene(scene)
      }
    }
    
    guard let touch = touches.first else{
      return
    }
    run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
    
    let touchLocation = touch.location(in: self)
    
    let projectile = SKSpriteNode(imageNamed: "projectile")
    projectile.position = player.position
    
    projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
    projectile.physicsBody?.isDynamic = true
    projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
    projectile.physicsBody?.contactTestBitMask = (PhysicsCategory.monster | PhysicsCategory.dragon) | PhysicsCategory.megaMonster
    projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
    projectile.physicsBody?.usesPreciseCollisionDetection = true
    
    let offset = touchLocation - projectile.position
    if offset.x < 0{return}
    addChild(projectile)
    //let direction = 1000*offset.normalized()
    let direction = offset.normalized()
    let shootAmount = direction*1000
    let realDest = projectile.position + shootAmount
    
    let actionMove = SKAction.move(to: realDest, duration: 2.0)
    let actionMoveDone = SKAction.removeFromParent()
    projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
  }
  
  func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode){
    projectile.removeFromParent()
    monster.removeFromParent()
    monstersDestroyed+=1
    points+=5
    label.text = "Kills: "+String(monstersDestroyed)
    score.text = "Score: "+String(points)
    writeHighScore(score: getHighScore())
    highScoreLabal.text = "High Score: "+String(highScore)
    if monstersDestroyed>100{
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      let gameOverScene = GameOverScene(size: self.size, won: true)
      view?.presentScene(gameOverScene, transition: reveal)
    }
  }
  
  func projectileDidCollideWithMegaMonster(projectile: SKSpriteNode, monster: RobustNode){
    projectile.removeFromParent()
    monster.numHits += 1
    if monster.numHits>=6 {
      monster.removeFromParent()
      monstersDestroyed+=6
      points+=45
      label.text = "Kills: "+String(monstersDestroyed)
      score.text = "Score: "+String(points)
      writeHighScore(score: getHighScore())
      highScoreLabal.text = "High Score: "+String(highScore)
      if monstersDestroyed>100{
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size, won: true)
        view?.presentScene(gameOverScene, transition: reveal)
      }
    }
  }
  
  func monsterDidCollideWithMegaMonster(monster: SKSpriteNode, megaMonster: RobustNode){
    monster.removeFromParent()
  }
  
  func projectileDidCollideWithDragon(projectile: SKSpriteNode, dragon: SKSpriteNode){
    projectile.removeFromParent()
    dragon.removeFromParent()
    points+=30
    writeHighScore(score: getHighScore())
    highScoreLabal.text = "High Score: "+String(highScore)
    score.text = "Score: "+String(points)
  }
}

class RobustNode: SKSpriteNode{
  var numHits = 0
}

extension GameScene: SKPhysicsContactDelegate{
  func didBegin(_ contact: SKPhysicsContact) {
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    
    if((firstBody.categoryBitMask & PhysicsCategory.monster != 0) && (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)){
      if let monster = firstBody.node as? SKSpriteNode, let projectile = secondBody.node as? SKSpriteNode {
        projectileDidCollideWithMonster(projectile: projectile, monster: monster)
      }
    }else if((firstBody.categoryBitMask & PhysicsCategory.projectile != 0) && (secondBody.categoryBitMask & PhysicsCategory.dragon != 0)){
      if let projectile = firstBody.node as? SKSpriteNode, let dragon = secondBody.node as? SKSpriteNode {
        projectileDidCollideWithDragon(projectile: projectile, dragon: dragon)
      }
    }else if((firstBody.categoryBitMask & PhysicsCategory.projectile != 0) && (secondBody.categoryBitMask & PhysicsCategory.megaMonster != 0)){
      if let projectile = firstBody.node as? SKSpriteNode, let megaMonster = secondBody.node as? RobustNode {
        projectileDidCollideWithMegaMonster(projectile: projectile, monster: megaMonster)
      }
    }else if((firstBody.categoryBitMask & PhysicsCategory.monster != 0) && (secondBody.categoryBitMask & PhysicsCategory.megaMonster != 0)){
      if let monster = firstBody.node as? SKSpriteNode, let megaMonster = secondBody.node as? RobustNode {
        monsterDidCollideWithMegaMonster(monster: monster, megaMonster: megaMonster)
      }
    }
  }
}
