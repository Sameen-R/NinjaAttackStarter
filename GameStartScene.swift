/// Copyright (c) 2021 Razeware LLC
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

class GameStartScene: SKScene{
  let startButton = SKSpriteNode()
  let startButtonLabel = SKLabelNode(fontNamed: "BanglaSangamMN-Bold")
  
  let restartButton = SKSpriteNode()
  let restartButtonLabel = SKLabelNode(fontNamed: "BanglaSangamMN-Bold")
  
  override func didMove(to view: SKView) {
    startButton.position = CGPoint(x: size.width/2, y: size.height*2/3)
    startButton.size = CGSize(width: CGFloat(160), height: CGFloat(80))
    startButton.color = SKColor.red
    startButton.isUserInteractionEnabled = true
    addChild(startButton)
    
    startButtonLabel.text = "Start Game"
    startButtonLabel.position = startButton.position
    startButtonLabel.fontSize = 25
    startButtonLabel.fontColor = SKColor.black
    addChild(startButtonLabel)
    
    restartButton.position = CGPoint(x: size.width/2, y: size.height/3)
    restartButton.size = CGSize(width: CGFloat(200), height: CGFloat(80))
    restartButton.color = SKColor.red
    restartButton.isUserInteractionEnabled = true
    addChild(restartButton)
    
    restartButtonLabel.text = "Reset High Score"
    restartButtonLabel.position = restartButton.position
    restartButtonLabel.fontSize = 18
    restartButtonLabel.fontColor = SKColor.white
    addChild(restartButtonLabel)
    
    backgroundColor = SKColor.white
    let label = SKLabelNode(fontNamed: "BanglaSangamMN-Bold")
    label.text = "Ninja Attack!"
    label.position = CGPoint(x: size.width/2, y: size.height*0.8)
    label.fontSize = 75
    label.fontColor = SKColor.red
    addChild(label)
    
    let ninja = SKSpriteNode(imageNamed: "playerV2")
    ninja.position = CGPoint(x: size.width/4, y: size.height*0.4)
    addChild(ninja)
    
    let ninjaStar = SKSpriteNode(imageNamed: "projectile")
    ninjaStar.position = CGPoint(x: size.width/2, y: size.height/2)
    addChild(ninjaStar)
    
    let monster = SKSpriteNode(imageNamed: "monsterV2")
    monster.position = CGPoint(x: size.width*0.9, y: size.height*0.4)
    addChild(monster)
    
    let dragon = SKSpriteNode(imageNamed: "dragon")
    dragon.position = CGPoint(x: size.width*0.8, y: size.height*0.4)
    addChild(dragon)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches{
      let location = touch.location(in: self)
      if startButton.contains(location){
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameScene = GameScene(size: self.size)
        view?.presentScene(gameScene, transition: reveal)
      }
      
      if restartButton.contains(location){
        let pop_up = SKSpriteNode()
        pop_up.position = CGPoint(x: size.width/2, y: size.height*2)
        pop_up.size = CGSize(width: CGFloat(300), height: CGFloat(300))
        pop_up.color = SKColor.black
        pop_up.isUserInteractionEnabled = true
        restartButton.isUserInteractionEnabled=false
        addChild(pop_up)
        
        let gameScene = GameScene()
        gameScene.resetHighScore()
      }
    }
  }
  
}
