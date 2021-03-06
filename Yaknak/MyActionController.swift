//
//  MyActionController.swift
//  Yaknak
//
//  Created by Sascha Melcher on 11/05/2017.
//  Copyright © 2017 Locals Labs. All rights reserved.
//

import UIKit

public enum MyActionControllerStyle {
    case ActionSheet
    case Alert
}

public enum MyButtonActionType {
    case Selector, Closure
}

public class MyActionController: UIViewController, UIGestureRecognizerDelegate {
    
    let ybTag = 2345
    
    // background
    public var overlayColor = UIColor(white: 0, alpha: 0.5)
    
    // titleLabel
    public var titleFont = UIFont.systemFont(ofSize: 17)
    public var titleTextColor = UIColor.primaryText()
    
    // message
    public var message: String?
    public var messageLabel = UILabel()
    public var messageFont = UIFont.systemFont(ofSize: 15)
    public var messageTextColor = UIColor.primaryText()
    
    // button
    public var buttonHeight: CGFloat = 50
    public var buttonTextColor = UIColor.primaryText()
    public var buttonIconColor: UIColor?
    public var buttons = [MyButton]()
    public var buttonFont = UIFont.systemFont(ofSize: 17)
    
    // cancelButton
    public var cancelButtonTitle: String?
    public var cancelButtonFont = UIFont.systemFont(ofSize: 15)
    public var cancelButtonTextColor = UIColor.secondaryText()
    
    public var animated = true
    public var containerView = UIView()
    public var style = MyActionControllerStyle.ActionSheet
    public var touchingOutsideDismiss:Bool? //
    
    private var instance: MyActionController!
    private var currentStatusBarStyle:UIStatusBarStyle?
    private var showing = false
    var previousEnabled = true
    private var currentOrientation:UIDeviceOrientation?
    private var cancelButton = UIButton()
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        view.frame = UIScreen.main.bounds
        
        containerView.backgroundColor = UIColor.white
        containerView.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MyActionController.dismiss as (MyActionController) -> () -> ()))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changedOrientation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    public convenience init(style: MyActionControllerStyle) {
        self.init()
        self.style = style
    }
    
    public convenience init(title:String?, message:String?, style: MyActionControllerStyle) {
        self.init()
        self.style = style
        self.title = title
        self.message = message
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func changedOrientation(notification: NSNotification) {
        if showing && style == MyActionControllerStyle.ActionSheet {
            let value = currentOrientation?.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            return
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touchingOutsideDismiss == false { return false }
        if touch.view != gestureRecognizer.view { return false }
        return true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show() {
        view.backgroundColor = overlayColor
        if touchingOutsideDismiss == nil {
            touchingOutsideDismiss = style == .ActionSheet ? true : false
        }
        
        initContainerView()
        
        if style == MyActionControllerStyle.ActionSheet {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 0,
                           options: .curveEaseIn,
                           animations: {
                            self.containerView.frame.origin.y = self.view.frame.height - self.containerView.frame.height
                         //   self.getTopViewController()?.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            },
                           completion: { (finished) in
                            if self.animated {
                                self.startButtonAppearAnimation()
                                if let cancelTitle = self.cancelButtonTitle, cancelTitle != "" {
                                    self.startCancelButtonAppearAnimation()
                                }
                                
                            }
            }
            )
        } else {
            self.containerView.frame.origin.y = self.view.frame.height/2 - self.containerView.frame.height/2
            containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            containerView.alpha = 0.0
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 0,
                           options: .curveEaseIn,
                           animations: {
                            self.containerView.alpha = 1.0
                            self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
            },
                           completion: { (finished) in
                            if self.animated {
                                self.startButtonAppearAnimation()
                                if let cancelTitle = self.cancelButtonTitle, cancelTitle != "" {
                                    self.startCancelButtonAppearAnimation()
                                }
                                
                            }
            }
            )
        }
    }
    
    public func dismiss() {
        showing = false
        if let statusBarStyle = currentStatusBarStyle {
            UIApplication.shared.statusBarStyle = statusBarStyle
        }
        
        if style == .ActionSheet {
            UIView.animate(withDuration: 0.2,
                           animations: {
                            self.containerView.frame.origin.y = self.view.frame.height
                            self.view.backgroundColor = UIColor(white: 0, alpha: 0)
                           // self.getTopViewController()?.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            },
                           completion:  { (finished) in
                            self.view.removeFromSuperview()
            })
        } else {
            UIView.animate(withDuration: 0.2,
                           animations: {
                            self.view.backgroundColor = UIColor(white: 0, alpha: 0)
                            self.containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                            self.containerView.alpha = 0
            },
                           completion:  { (finished) in
                            self.view.removeFromSuperview()
            })
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while topVC?.presentedViewController != nil {
            topVC = topVC?.presentedViewController
        }
        return topVC
    }
    
    private func initContainerView() {
        
        for subView in containerView.subviews {
            subView.removeFromSuperview()
        }
        for subView in self.view.subviews {
            subView.removeFromSuperview()
        }
        
        showing = true
        instance = self
        let viewWidth = (style == .ActionSheet) ? view.frame.width : view.frame.width * 0.9
        
        currentOrientation = UIDevice.current.orientation
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation == UIInterfaceOrientation.portrait {
            currentOrientation = UIDeviceOrientation.portrait
        }
        
        var posY:CGFloat = 0
        if let title = title, title != ""  {
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewWidth, height: buttonHeight*0.92))
            titleLabel.text = title
            titleLabel.font = titleFont
            titleLabel.textAlignment = .center
            titleLabel.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin]
            titleLabel.textColor = titleTextColor
            containerView.addSubview(titleLabel)
            
            let line = UIView(frame: CGRect(x: 0, y: titleLabel.frame.height, width: viewWidth, height: 1))
            line.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            line.autoresizingMask = [.flexibleWidth]
            containerView.addSubview(line)
            posY = titleLabel.frame.height + line.frame.height
        } else {
            posY = 0
        }
        
        if let message = message, message != "" {
            let paddingY: CGFloat = 16
            let paddingX: CGFloat = 10
            messageLabel.font = messageFont
            messageLabel.textColor = UIColor.gray
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.text = message
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            messageLabel.textColor = messageTextColor
            let f = CGSize(width: viewWidth - paddingX*2, height: CGFloat.greatestFiniteMagnitude)
            let rect = messageLabel.sizeThatFits(f)
            messageLabel.frame = CGRect(x: paddingX, y: posY + paddingY, width: rect.width, height: rect.height)
            containerView.addSubview(messageLabel)
            containerView.addConstraints([
                NSLayoutConstraint(item: messageLabel, attribute: .rightMargin, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: .rightMargin, multiplier: 1, constant: -paddingX),
                NSLayoutConstraint(item: messageLabel, attribute: .leftMargin, relatedBy: .equal, toItem: containerView, attribute: .leftMargin, multiplier: 1.0, constant: paddingX),
                NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: posY + paddingY),
                NSLayoutConstraint(item: messageLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: rect.height)
                ])
            
            posY = messageLabel.frame.maxY + paddingY
            
            let line = UIView(frame: CGRect(x: 0, y: posY, width: viewWidth, height: 1))
            line.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            line.autoresizingMask = [.flexibleWidth]
            containerView.addSubview(line)
            
            posY += line.frame.height
        }
        
        for i in 0..<buttons.count {
            buttons[i].frame.origin.y = posY
            buttons[i].backgroundColor = UIColor.white
            buttons[i].buttonColor = buttonIconColor
            buttons[i].frame = CGRect(x: 0, y: posY, width: viewWidth, height: buttonHeight)
         //   buttons[i].textLabel.textColor = buttonTextColor
         //   if (style == .Alert) {
         //    buttons[i].titleLabel?.textAlignment = .center
         //   }
         //   buttons[i].buttonFont = buttonFont
            buttons[i].translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(buttons[i])
            
            containerView.addConstraints([
                NSLayoutConstraint(item: buttons[i], attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: buttonHeight),
                NSLayoutConstraint(item: buttons[i], attribute: NSLayoutAttribute.rightMargin, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.rightMargin, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: buttons[i], attribute: NSLayoutAttribute.leftMargin, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.leftMargin, multiplier: 1.0, constant: 16),
                NSLayoutConstraint(item: buttons[i], attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: posY)
                ])
        
            posY += buttons[i].frame.height
        }
        
        if let cancelTitle = cancelButtonTitle, cancelTitle != "" {
            cancelButton = UIButton(frame: CGRect(x: 0, y: posY, width: viewWidth, height: buttonHeight * 0.9))
            cancelButton.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin]
            cancelButton.titleLabel?.font = cancelButtonFont
            cancelButton.setTitle(cancelButtonTitle, for: .normal)
            cancelButton.setTitleColor(cancelButtonTextColor, for: .normal)
            cancelButton.addTarget(self, action: #selector(MyActionController.dismiss as (MyActionController) -> () -> ()), for: .touchUpInside)
            containerView.addSubview(cancelButton)
            posY += cancelButton.frame.height
        }
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.frame = CGRect(x: (view.frame.width - viewWidth) / 2, y:view.frame.height , width: viewWidth, height: posY)
        containerView.backgroundColor = UIColor.white
        if (style == .Alert) {
        containerView.layer.cornerRadius = 4
        }
        view.addSubview(containerView)
        
        
        
        if style == MyActionControllerStyle.ActionSheet {
            self.view.addConstraints([
                NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.centerX, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: posY)
                ])
        } else {
            self.view.addConstraints([
                NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.9, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.centerX, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.centerY, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: posY)
                ])
        }
        
        if let window = UIApplication.shared.keyWindow {
            if window.viewWithTag(ybTag) == nil {
                view.tag = ybTag
                window.addSubview(view)
            }
        }
        
        currentStatusBarStyle = UIApplication.shared.statusBarStyle
        if style == .ActionSheet { UIApplication.shared.statusBarStyle = .lightContent }
        
        /*
        if animated {
            cancelButton.isHidden = true
            buttons.forEach {
              //  $0.textLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
            }
        }
        */
    }
    
    private func startButtonAppearAnimation() {
        let delay = 0.2
        
        for i in 0..<buttons.count {
            let time = DispatchTime.now() + (delay * Double(i))
            DispatchQueue.main.asyncAfter(deadline: time){
                self.buttons[i].appear()
            }
        }
    }
    
    private func startCancelButtonAppearAnimation() {
        cancelButton.titleLabel?.transform = CGAffineTransform(scaleX: 0, y: 0)
        cancelButton.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0.2 * Double(buttons.count + 1) - 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            self.cancelButton.titleLabel?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
    }
    
    public func addButton(_ title: String, _ enabled: Bool, _ action:@escaping ()->Void) {
        let button = MyButton(CGRect(x: 0, y: 0, width: view.frame.width, height: buttonHeight), title)
        button.actionType = MyButtonActionType.Closure
        button.action = action
        button.buttonColor = buttonTextColor
        button.contentHorizontalAlignment = .left
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.primaryText(), for: .normal)
        if !enabled {
        button.isEnabled = false
            button.setTitleColor(UIColor.secondaryText(), for: .normal)

        }
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        buttons.append(button)
    }
    
    public func addButton(_ title: String, _ enabled: Bool, _ target: AnyObject, selector: Selector) {
        let button = MyButton(CGRect(x: 0, y: 0, width: view.frame.width, height: buttonHeight), title)
        button.actionType = MyButtonActionType.Selector
        button.buttonColor = buttonTextColor
        button.contentHorizontalAlignment = .left
        button.target = target
        button.selector = selector
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.primaryText(), for: .normal)
        if !enabled {
            button.isEnabled = false
            button.setTitleColor(UIColor.secondaryText(), for: .normal)

        }
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        buttons.append(button)
    }
   /*
    public func addButton(_ title: String, _ enabled: Bool, _ action:@escaping ()->Void) {
        addButton(title, enabled, action)
    }
 
    public func addButton(_ title: String, _ target: AnyObject, selector: Selector) {
        //        addButton(icon: nil, title: title, target: target, selector: selector)
        let button = MyButton(CGRect(x: 0, y: 0, width: view.frame.width, height: buttonHeight), title)
        button.actionType = MyButtonActionType.Selector
        button.buttonColor = buttonTextColor
        button.setTitle(title, for: .normal)
        button.target = target
        button.selector = selector
     //   button.buttonFont = buttonFont
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        buttons.append(button)
    }
 */
    
    func buttonTapped(button:MyButton) {
        if button.actionType == MyButtonActionType.Closure {
            button.action()
        } else if button.actionType == MyButtonActionType.Selector {
            let control = UIControl()
            control.sendAction(button.selector, to: button.target, for: nil)
        }
        dismiss()
    }
}

public class MyButton : UIButton {
    
    override public var isHighlighted : Bool {
        didSet {
            alpha = isHighlighted ? 0.3 : 1.0
        }
    }
    var buttonColor: UIColor? {
        didSet {
            if let buttonColor = buttonColor {
                self.tintColor = buttonColor
              //  self.textColor = buttonColor
              //  dotView.dotColor = buttonColor
            }
        }
    }
    
    /*
  //  var textLabel = UILabel()
    var buttonFont: UIFont? {
        didSet {
            self.font = buttonFont!
        }
    }
    */
    var actionType: MyButtonActionType!
    var target: AnyObject!
    var selector: Selector!
    var action: (()->Void)!
    
    init(_ frame:CGRect, _ text: String) {
        super.init(frame:frame)
        
     //   self.icon = icon
     //   let iconHeight:CGFloat = frame.height * 0.45
     //   iconImageView.frame = CGRect(x: 9, y: frame.height/2 - iconHeight/2, width: iconHeight, height: iconHeight)
     //   iconImageView.image = icon
     //   addSubview(iconImageView)
        
     //   dotView.frame = iconImageView.frame
     //   dotView.backgroundColor = UIColor.clear
     //   dotView.isHidden = true
     //   addSubview(dotView)
      /*
        let labelHeight = frame.height * 0.8
        textLabel.frame = CGRect(x: 15, y: frame.midY - labelHeight/2, width: frame.width, height: labelHeight)
        textLabel.text = text
        textLabel.textColor = UIColor.black
        textLabel.font = buttonFont
        addSubview(textLabel)
 */
    }
    
    func appear() {
    //    iconImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
    //    textLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
    //    dotView.transform = CGAffineTransform(scaleX: 0, y: 0)
    //    dotView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
           // self.textLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveLinear, animations: {
            
            /*
            if self.iconImageView.image == nil {
                self.dotView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            } else {
                self.iconImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            */
        }, completion: nil)
    }
    
    required public init?(coder aDecoder:NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func draw(_ rect: CGRect) {
        UIColor(white: 0.85, alpha: 1.0).setStroke()
        let line = UIBezierPath()
        line.lineWidth = 1
        line.move(to: CGPoint(x: frame.minX + 12, y: frame.height))
        line.addLine(to: CGPoint(x: frame.width , y: frame.height))
        line.stroke()
    }
}
