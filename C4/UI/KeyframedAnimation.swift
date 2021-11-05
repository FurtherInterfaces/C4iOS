//
//  KeyframedAnimation.swift
//  C4
//
//  Created by Phillip Pasqual on 10/4/21.
//

/// KeyframedAnimation is a concrete subclass of Animation.
///
/// A KeyframedAnimation object is able to apply a set of keyframed animations.
///
/// This class is useful for serializing and deserializing animations.
public class KeyframedAnimation: Animation {
    public var delay: TimeInterval = 0
    public var animations: (Double) -> Void
    
    public init(_ animations: @escaping (Double) -> Void) {
        self.animations = animations
    }

    public convenience init(duration: TimeInterval, animations: @escaping (Double) -> Void) {
        self.init(animations)
        self.duration = duration
    }
    
    public var keyframeOptions: UIView.KeyframeAnimationOptions  {
        var options: UIView.KeyframeAnimationOptions = [UIView.KeyframeAnimationOptions.beginFromCurrentState]
        
        options = [options, .calculationModeDiscrete]

        if autoreverses == true {
            options.formUnion(.autoreverse)
        } else {
            options.subtract(.autoreverse)
        }

        if repeatCount > 0 {
            options.formUnion(.repeat)
        } else {
            options.subtract(.repeat)
        }
        return options
    }
    
    /// Initiates the changes specified in the receivers `animations` block.
    public override func animate() {
        let disable = ShapeLayer.disableActions
        ShapeLayer.disableActions = false

        wait(delay) {
            UIView.animateKeyframes(withDuration: self.duration, delay: 0, options: self.keyframeOptions, animations: self.animationBlock)
        }

        ShapeLayer.disableActions = disable
    }
    
    private func animationBlock() {
        for i in stride(from: 0.0, through: 1.0, by: 0.2) {
            UIView.addKeyframe(withRelativeStartTime: i, relativeDuration: 0.2) {
                //self.actions
            }
        }
        
        ViewAnimation.stack.append(self)
        UIView.setAnimationRepeatCount(Float(self.repeatCount))
        self.doInTransaction(action: self.animations)
        ViewAnimation.stack.removeLast()
    }

    private func doInTransaction(action: @escaping (Double) -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        //CATransaction.setAnimationTimingFunction(timingFunction)
        CATransaction.setCompletionBlock({
            self.postCompletedEvent()
        })
        /*for i in stride(from: 0.0, through: 1.0, by: 0.2) {
            UIView.addKeyframe(withRelativeStartTime: i, relativeDuration: 0.2) {
                action(i)
            }
        }*/
        action(0.2)
        /*UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2) {
            
        }
        
        UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2) {
            action(0.4)
        }
        
        UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.2) {
            action(0.6)
        }
        
        UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.2) {
            action(0.8)
        }
        
        UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
            action(1.0)
        }*/
        
        CATransaction.commit()
    }
}
