//
//  SoundsController.swift
//  PetSelfieAppTake3
//
//  Created by Cory Green on 3/28/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import AVFoundation

class SoundsController: NSObject, AVAudioPlayerDelegate {
    
    override init() {
        super.init()
    }
    
    // **** play sound stuff **** //
    func playSound(name:String){
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else{
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: AVAudioSession.Mode.default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            ViewController.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = ViewController.player else {
                return
            }
            player.delegate = self
            player.numberOfLoops = 10
            player.play()
        } catch let error{
            print(error.localizedDescription)
        }
    }
    
    func stopSound(){
        if(ViewController.player != nil){
            ViewController.player?.stop()
        }
    }

}
