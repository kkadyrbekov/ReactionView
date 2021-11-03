import Foundation
import UIKit
import Lottie

public struct Reaction {
    var title: String
    var lottieView: AnimationView
    var tag: Int?
}

public protocol ReactionViewDelegate: AnyObject {
    func didSelect(reaction: Reaction, view: ReactionView)
}

public class ReactionView: UIView {
    
    private var sourceView: UIView!
    private var gestureView: UIView!
    private var reactions: [Reaction]!
    weak var delegate: ReactionViewDelegate?
    
    private let iconHeight: CGFloat = 36
    private let padding: CGFloat = 8
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        layer.shadowRadius = 20
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupWith(delegate: UIViewController, reactions: [Reaction], sourceView: UIView, gestureView: UIView) {
        self.reactions = reactions
        self.sourceView = sourceView
        self.gestureView = gestureView
        self.delegate = delegate as? ReactionViewDelegate
        
        var arrangedSubviews: [UIView] = []
        
        for (index, reaction) in reactions.enumerated() {
            let view = reaction.lottieView
            view.isUserInteractionEnabled = true
            view.frame = CGRect(x: 0, y: 0, width: iconHeight, height: iconHeight)
            view.layer.cornerRadius = (view.frame.height) / 2
            view.layer.masksToBounds = true
            view.layer.borderColor = UIColor.clear.cgColor
            view.layer.borderWidth = 0
            view.contentMode = .scaleAspectFit
            view.tag = index
            self.reactions[index].tag = index
            arrangedSubviews.append(view)
        }
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        stackView.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let width = (CGFloat(self.reactions.count) * iconHeight) + (CGFloat(self.reactions.count + 1) * padding)
        self.frame = CGRect(x: 0, y: 0, width: width, height: iconHeight + 2 * padding)
        layer.cornerRadius = frame.height/2
        addSubview(stackView)
        stackView.frame = frame
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        gestureView.addGestureRecognizer(longPressGesture)
        
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            sourceView.addSubview(self)
            showViewWithAnimation(at: gesture.location(in: sourceView), in: sourceView)
        case .changed:
            performHittestOnView(at: gesture.location(in: self))
        case .ended:
            removeViewWithAnimation(at: gesture.location(in: self))
        default:
            break
        }
    }
    
    public func showViewWithAnimation(at point: CGPoint, in view: UIView) {
        reactions.forEach { reaction in
            reaction.lottieView.play()
        }
        
        alpha = 0
        
        let centerX = view.frame.maxX / 4
        transform = CGAffineTransform(translationX: centerX, y: point.y)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.alpha = 1
            self.transform = CGAffineTransform(translationX: centerX, y: point.y - 80)
        }) { (_) in
            let lbl = UILabel()
            lbl.frame = CGRect(x: 8, y: 2.5, width: lbl.frame.width, height: 22)
            lbl.textColor = .white
            let bgView = UIView(frame: CGRect(x: 120, y: -54, width: lbl.frame.width + 16, height: lbl.frame.height + 4))
            bgView.alpha = 0
            bgView.addSubview(lbl)
            bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            bgView.layer.cornerRadius = bgView.frame.height / 2
            self.addSubview(bgView)
        }
    }
    
    public func performHittestOnView(at point: CGPoint) {
        let fixedYlocation = CGPoint(x: point.x, y: point.y > 16 ? (self.frame.height / 2)  : point.y)
        guard let hitTestview = hitTest(fixedYlocation, with: nil) else { return }
        
        if hitTestview is AnimationView {
            UIView.animate(withDuration: 0.3) {
                let stackView = self.subviews.first
                stackView?.subviews.forEach({ (imgView) in
                    if imgView != hitTestview {
                        imgView.transform = .identity
                    } else {
                        hitTestview.transform = CGAffineTransform(scaleX: 1.8, y: 1.8).translatedBy(x: -0.25, y: -10)
                    }
                })
                
                let titles = self.reactions.map { (reaction) -> String in
                    return reaction.title
                }
                
                for allViews in self.subviews {
                    for label in allViews.subviews {
                        if let lbl = label as? UILabel {
                            lbl.tag = hitTestview.tag
                            lbl.text = titles[hitTestview.tag]
                            allViews.frame.size.width = label.frame.width + 16
                            allViews.center.x = (point.x)
                            allViews.alpha = 1
                            lbl.sizeToFit()
                        }
                    }
                }
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                let stackView = self.subviews.first
                stackView?.subviews.forEach({ (imgView) in
                    imgView.transform = .identity
                })
            }
            for vw in self.subviews{
                for lblView in  vw.subviews {
                    if lblView is UILabel {
                        vw.alpha = 0
                        break
                    }
                }
            }
        }
    }
    
    public func removeViewWithAnimation(at point: CGPoint) {
        let fixedYlocation = CGPoint(x: point.x, y: point.y > 16 ? (self.frame.height / 2) : point.y)
        let hitTestview = self.hitTest(fixedYlocation, with: nil)
        if hitTestview is AnimationView {
            self.delegate?.didSelect(reaction: reactions[hitTestview!.tag], view: self)
        }
        resetIconContainer()
    }
    
    private func resetIconContainer() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            let stackView = self.subviews.first
            stackView?.subviews.forEach({ (imgView) in
                imgView.transform = .identity
                self.transform = self.transform.translatedBy(x: 0, y: 20)
                self.alpha = 0
            })
        })  { (_) in
            for vw in self.subviews{
                for lblView in  vw.subviews {
                    if lblView is UILabel {
                        vw.removeFromSuperview()
                        break
                    }
                }
            }
            self.removeFromSuperview()
        }
    }
}
