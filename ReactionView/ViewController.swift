//
//  ViewController.swift
//  ReactionView
//
//  Created by Kuban Kadyrbekov on 3/11/21.
//

import UIKit
import Lottie

class ViewController: UIViewController {
    
    var btnReaction: UIButton!
    var reactionView: ReactionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnReaction = UIButton(frame: CGRect(x: 100, y: 300, width: 200, height: 30))
        btnReaction.setTitle("Long Press here", for: .normal)
        btnReaction.setTitleColor(UIColor.red, for: .normal)
        view.addSubview(btnReaction)
        
        reactionView = ReactionView()
        
        var reactions: [Reaction] = []
        let titles: [String] = ["Love", "Hater", "LOL!", "WOW"]
        let lottieItems: [String] = ["heart", "angry", "lol", "wow"]
        
        for i in 0..<lottieItems.count {
            let lottieView1 = AnimationView(name: lottieItems[i])
            lottieView1.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
            lottieView1.loopMode = .loop
            lottieView1.backgroundBehavior = .pauseAndRestore
            let reaction = Reaction(title: titles[i], lottieView: lottieView1)
            reactions.append(reaction)
        }
        
        reactionView?.setupWith(delegate: self , reactions: reactions, sourceView: self.view, gestureView: btnReaction)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - FacebookLikeReactionDelegate
extension ViewController: ReactionViewDelegate {
    func didSelect(reaction: Reaction, view: ReactionView) {
        print("Selected-------\(reaction.title)")
    }
}
