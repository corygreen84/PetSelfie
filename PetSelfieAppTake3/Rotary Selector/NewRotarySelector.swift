//
//  NewRotarySelector.swift
//  PetSelfieAppTake3
//
//  Created by Cory Green on 3/14/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit

@objc protocol ReturnRotaryDelegate{
    func centerButtonTap(open:Bool)
    func centerButtonLongTap(beginEnd:Bool)
}



class NewRotarySelector: NSObject, UIGestureRecognizerDelegate {

    var mainView:UIView?
    var mainViewFrame:CGRect?
    
    // this is essentially the same circle as the top only with a //
    // hole in the top //
    var selectedView:UIView?
    var selectedWindow:UIView?
    
    
    var mainViewBottomBar:UIView?
    
    var mainButton:UIButton?
    
    var rotaryView:UIView?
    var rotaryViewOut = false
    
    var restingRotation:CGFloat = 0.0
    
    var delegate:ReturnRotaryDelegate?
    
    
    init(view:UIView) {
        super.init()
        
        mainView = view
        startRotaryViewSetup()
    }
    
    func startRotaryViewSetup(){

        // solid bar at the bottom of the screen //
        mainViewFrame = mainView?.bounds
        
        // bottom solid frame bar //
        mainViewBottomBar = UIView(frame: CGRect(x: 0, y: (mainViewFrame?.origin.y)! + (mainViewFrame?.size.height)! - 100, width: (mainViewFrame?.size.width)!, height: 180))
        
        mainViewBottomBar?.backgroundColor = UIColor(red:0.90, green:0.49, blue:0.15, alpha:1.0)
        mainViewBottomBar?.layer.zPosition = 3

        mainView?.addSubview(mainViewBottomBar!)
        
        
        // main button //
        mainButton = UIButton(frame: CGRect(x: 0, y: (mainViewFrame?.origin.y)! + (mainViewFrame?.size.height)! - 160, width: 100, height: 100))
        mainButton?.center.x = (mainViewFrame?.size.width)! / 2

        mainButton?.setImage(UIImage(named: "paw-circle"), for: UIControl.State.normal)
        // mainButton?.image
        mainButton?.layer.cornerRadius = (self.mainButton?.frame.size.width)! / 2
        mainButton?.layer.zPosition = 4

        
        let centerButtonTapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(centerButtonPressed))
        
        let centerButtonLongPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(centerButtonLongPress))
        
        
        // adding gesture recognizer to the main buttons //
        mainButton?.addGestureRecognizer(centerButtonTapGesture)
        mainButton?.addGestureRecognizer(centerButtonLongPressGesture)
        
        
        
        
        // expanding rotary view //
        rotaryView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        rotaryView?.center = (self.mainButton?.center)!
        rotaryView?.layer.cornerRadius = (self.rotaryView?.frame.size.width)! / 2
        rotaryView?.backgroundColor = UIColor(red: 210.0/255.0, green: 215.0/255.0, blue: 211.0/255.0, alpha: 0.75)
        rotaryView?.layer.zPosition = 1

        
        
        
        // this is an overlaying circle that shows the user what sound is //
        // currently selected //
        
        selectedView = UIView()
        selectedView?.frame = rotaryView!.bounds
        selectedView?.center = rotaryView!.center
        selectedView?.backgroundColor = UIColor.clear
        selectedView?.layer.zPosition = 2
        selectedView?.layer.borderColor = UIColor(red:0.90, green:0.49, blue:0.15, alpha:1.0).cgColor
        selectedView?.layer.borderWidth = 3.0
        selectedView?.layer.cornerRadius = (self.selectedView?.frame.size.width)! / 2
        
        // this is for rotating the view //
        let newRecognizer:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(rotationGesture))
        newRecognizer.minimumPressDuration = 0.01
        selectedView!.addGestureRecognizer(newRecognizer)
 
 
        
        // selected window //
        selectedWindow = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        selectedWindow?.center = CGPoint(x: (self.selectedView?.frame.size.width)! / 2, y: 0)
        selectedWindow?.layer.cornerRadius = (self.selectedWindow?.frame.size.width)! / 2
        selectedWindow?.backgroundColor = UIColor.clear
        selectedWindow?.layer.borderColor = UIColor(red:0.90, green:0.49, blue:0.15, alpha:1.0).cgColor
        selectedWindow?.layer.borderWidth = 4.0
        
        selectedView!.addSubview(selectedWindow!)
        
        
        
        
        
        
        
        
        
        
        
        
        let centerPoint = CGPoint(x: (self.rotaryView?.frame.size.width)! / 2, y: (self.rotaryView?.frame.size.height)! / 2)
        
        // the individual buttons in the rotary dial //
        let topButton:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        topButton.setImage(UIImage(named: "cat"), for: UIControl.State.normal)
        topButton.backgroundColor = UIColor.white
        topButton.center = centerPoint
        topButton.layer.cornerRadius = topButton.frame.size.width / 2
        topButton.layer.zPosition = 1
        topButton.tag = 0
        rotaryView?.addSubview(topButton)
        
        let tenOClockButton:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tenOClockButton.setImage(UIImage(named: "dog-1"), for: UIControl.State.normal)
        tenOClockButton.backgroundColor = UIColor.white
        tenOClockButton.center = centerPoint
        tenOClockButton.layer.cornerRadius = tenOClockButton.frame.size.width / 2
        tenOClockButton.layer.zPosition = 1
        tenOClockButton.tag = 1
        rotaryView?.addSubview(tenOClockButton)
        
        
        let twoOClockButton:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        twoOClockButton.setImage(UIImage(named: "chicken"), for: UIControl.State.normal)
        twoOClockButton.backgroundColor = UIColor.white
        twoOClockButton.center = centerPoint
        twoOClockButton.layer.cornerRadius = twoOClockButton.frame.size.width / 2
        twoOClockButton.layer.zPosition = 1
        twoOClockButton.tag = 2
        rotaryView?.addSubview(twoOClockButton)
        
        
        let sixOClockButton:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        sixOClockButton.setImage(UIImage(named: "NoSound"), for: UIControl.State.normal)
        sixOClockButton.backgroundColor = UIColor.white
        sixOClockButton.center = centerPoint
        sixOClockButton.layer.cornerRadius = sixOClockButton.frame.size.width / 2
        sixOClockButton.layer.zPosition = 1
        sixOClockButton.tag = 3
        rotaryView?.addSubview(sixOClockButton)
        
        
        let threeOClockButton:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        threeOClockButton.backgroundColor = UIColor.black
        threeOClockButton.center = centerPoint
        threeOClockButton.layer.cornerRadius = threeOClockButton.frame.size.width / 2
        threeOClockButton.layer.zPosition = 1
        threeOClockButton.tag = 4
        rotaryView?.addSubview(threeOClockButton)
        
        
        
        
        
        mainView?.addSubview(rotaryView!)
        mainView?.addSubview(selectedView!)
        mainView?.addSubview(mainButton!)
        
    }
    
    
    
    
    @objc func outterButtonPressed(){
        
    }
    
    @objc func centerButtonPressed(){
        if(rotaryViewOut == false){
            
            self.rotaryView?.transform = CGAffineTransform(rotationAngle: 0.0)
            
            UIView.animate(withDuration: 0.2, animations: {
                self.rotaryView?.frame = CGRect(x: 0, y: 0, width: (self.mainButton?.frame.size.width)! * 2.5, height: (self.mainButton?.frame.size.height)! * 2.5)
                self.rotaryView?.center = (self.mainButton?.center)!
                self.rotaryView?.layer.cornerRadius = (self.rotaryView?.frame.size.width)! / 2
                
                
                
                // putting out the top layer view //
                self.selectedView?.frame = (self.rotaryView?.bounds)!
                self.selectedView?.center = (self.rotaryView?.center)!
                self.selectedView?.layer.cornerRadius = (self.rotaryView?.frame.size.width)! / 2
                
                
                self.selectedWindow?.frame = CGRect(x: (self.selectedView?.frame.size.width)! / 2, y: 0, width: 50, height: 50)
                self.selectedWindow?.center = CGPoint(x: (self.selectedView?.frame.size.width)! / 2, y: 30)
                self.selectedWindow?.layer.cornerRadius = (self.selectedWindow?.frame.size.width)! / 2
                
                
                
                self.rotaryViewOut = true
                
                
                for buttons in (self.rotaryView?.subviews)!{
                    if(buttons.isKind(of: UIButton.self)){
                        buttons.isHidden = false
                        if(buttons.tag == 0){
                            buttons.frame.size = CGSize(width: 50, height: 50)
                            buttons.layer.cornerRadius = buttons.frame.size.width / 2
                            buttons.center = CGPoint(x: (self.rotaryView?.frame.size.width)! / 2, y: 30)
                            //self.rotaryView!.bringSubviewToFront(buttons)
                        }else if(buttons.tag == 1){
                            buttons.frame.size = CGSize(width: 50, height: 50)
                            buttons.layer.cornerRadius = buttons.frame.size.width / 2
                            buttons.center = CGPoint(x: (self.rotaryView?.frame.size.width)! / 4 - 10, y: (self.rotaryView?.frame.size.height)! / 4)
                        }else if(buttons.tag == 2){
                            buttons.frame.size = CGSize(width: 50, height: 50)
                            buttons.layer.cornerRadius = buttons.frame.size.width / 2
                            buttons.center = CGPoint(x: (self.rotaryView?.frame.size.width)! - (self.rotaryView?.frame.size.width)! / 4 + 10, y: (self.rotaryView?.frame.size.height)! / 4)
                        }else if(buttons.tag == 3){
                            buttons.frame.size = CGSize(width: 50, height: 50)
                            buttons.layer.cornerRadius = buttons.frame.size.width / 2
                            buttons.center = CGPoint(x: 30, y: (self.rotaryView?.frame.size.height)! / 2)
                            
                        }else if(buttons.tag == 4){
                            buttons.frame.size = CGSize(width: 50, height: 50)
                            buttons.layer.cornerRadius = buttons.frame.size.width / 2
                            buttons.center = CGPoint(x: (self.rotaryView?.frame.size.width)! - 30, y: (self.rotaryView?.frame.size.height)! / 2)
                        }
                    }
                }

            }) { (complete) in
                self.delegate?.centerButtonTap(open: true)
            }
        }else{
            
            self.closeOutterCircle()
        }
    }
    
    
    
    func closeOutterCircle(){
        UIView.animate(withDuration: 0.2, animations: {
            self.rotaryView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.rotaryView?.center = (self.mainButton?.center)!
            self.rotaryView?.layer.cornerRadius = (self.rotaryView?.frame.size.width)! / 2
            self.rotaryViewOut = false
            
            // closing the top layer //
            self.selectedView?.frame = (self.rotaryView?.bounds)!
            self.selectedView?.center = (self.rotaryView?.center)!
            self.selectedView?.layer.cornerRadius = (self.selectedView?.frame.size.width)! / 2
            
            
            // closing the selected window //
            self.selectedWindow?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.selectedWindow?.center = (self.rotaryView?.center)!
            self.selectedWindow?.layer.cornerRadius = (self.selectedWindow?.frame.size.width)! / 2
            
            
            for buttons in (self.rotaryView?.subviews)!{
                if(buttons.isKind(of: UIButton.self)){
                    buttons.center = CGPoint(x: (self.rotaryView?.frame.size.width)! / 2, y: (self.rotaryView?.frame.size.height)! / 2)
                    buttons.isHidden = true
                }
            }
        }) { (complete) in
            self.delegate?.centerButtonTap(open: false)
            self.restingRotation = 0.0
            
            for buttons in (self.rotaryView?.subviews)!{
                if(buttons.isKind(of: UIButton.self)){
                    buttons.transform = CGAffineTransform(rotationAngle: -self.restingRotation)
                }
            }
        }
    }
    
    
    
    
    @objc func centerButtonLongPress(gesture:UILongPressGestureRecognizer){
        if(gesture.state == .began){
            self.delegate?.centerButtonLongTap(beginEnd: true)
        }else if(gesture.state == .ended){
            self.delegate?.centerButtonLongTap(beginEnd: false)
        }
    }
    
    
    // this will be used to rotate the rotary view //
    @objc func rotationGesture(gesture:UILongPressGestureRecognizer){

        let location = gesture.location(in: self.rotaryView)
        
        let centerOfMainButton = self.mainButton?.center
        let centerOfMainButtonY = Float((self.mainView?.frame.size.height)!) - Float((self.mainButton?.center.y)!)
        
        let deltaX = (centerOfMainButton?.x)! - location.x
        let deltaY = CGFloat(centerOfMainButtonY) - location.y
        
        let rad:CGFloat = CGFloat(atan2f(Float(deltaY), Float(deltaX)))
        
        restingRotation = restingRotation + rad
        
        self.rotaryView?.transform = CGAffineTransform(rotationAngle: restingRotation)
        
        
        for buttons in (self.rotaryView?.subviews)!{
            if(buttons.isKind(of: UIButton.self)){
                buttons.transform = CGAffineTransform(rotationAngle: -restingRotation)
            }
        }
    }
}
