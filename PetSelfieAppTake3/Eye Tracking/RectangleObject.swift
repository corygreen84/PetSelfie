//
//  RectangleObject.swift
//  PetSelfieAppTake3
//
//  Created by Cory Green on 3/10/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit

class RectangleObject: NSObject {
    
    static var instanceCount:Int = 0
    
    var _view:UIView?
    var _index:Int?
    var rectangleView:UIView?
    
    
    init(view:UIView, index:Int) {
        super.init()
        
        RectangleObject.instanceCount += 1
        
        _view = view
        _index = index
        
        // setting up the rectangle //
        self.setupRectangle()
    }
    
    
    func setupRectangle(){
        // creating the rectangle views //
        
        print("index -> \(_index!)")

        rectangleView = UIView()
        rectangleView!.tag = _index!
        rectangleView!.backgroundColor = .clear
        rectangleView!.layer.cornerRadius = 5.0
        rectangleView!.layer.borderColor = UIColor.blue.cgColor
        rectangleView!.layer.borderWidth = 2.0
        
        
        _view?.addSubview(rectangleView!)
        
    }
    
    func updateLocation(frame:CGRect){
        rectangleView?.frame = frame
    }
    
    func removeFromView(){
        DispatchQueue.main.async{
            self.rectangleView?.removeFromSuperview()
        }
    }
    
    
    deinit {
        RectangleObject.instanceCount -= 1
        
    }
    
    
    
    
}
