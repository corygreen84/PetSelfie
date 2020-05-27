//
//  ViewController.swift
//  PetSelfieAppTake3
//
//  Created by Cory Green on 2/25/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVAudioPlayerDelegate, AVCapturePhotoCaptureDelegate, ReturnRotaryDelegate {

    @IBOutlet weak var mainCameraView: UIView!
    
    var mainSwitch:UISwitch?

    var selectedSound:String = "NoSound"
    var newRotarySelector:NewRotarySelector?
    
    // sound stuff //
    static var player: AVAudioPlayer?
    
    
    var countDownTimerLabel:UILabel?
    
    // timer stuff //
    var timer:Timer?
    var timerCount = 0

    // eye tracking //
    //var eyeTracking:EyeTrackingObject?
    var eyeTrackingToggle = false
    
    var cameraObject:CameraObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // navigation bar stuff //
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.90, green:0.49, blue:0.15, alpha:1.0)

        let microphoneButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "microphone"), style: .plain, target: self, action: #selector(microphoneButtonOnClick))
        microphoneButton.tintColor = UIColor.white
        
        let settingsButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings.png"), style: .plain, target: self, action: #selector(settingsButtonOnClick))
        settingsButton.tintColor = UIColor.white

        self.navigationItem.leftBarButtonItem = settingsButton
        self.navigationItem.rightBarButtonItem = microphoneButton

        
        // creating the eye tracking toggle from scratch //
        mainSwitch = UISwitch(frame: CGRect(x: 20, y: 120, width: 50, height: 30))
        mainSwitch!.layer.zPosition = 1
        mainSwitch!.setOn(false, animated: true)
        mainSwitch!.addTarget(self, action: #selector(mainSwitchOnChange(_:)), for: UIControl.Event.valueChanged)
        self.view.addSubview(mainSwitch!)

        
        
        // count down timer label //
        countDownTimerLabel = UILabel(frame: CGRect(x: 0, y: 0, width:60, height: 60))
        countDownTimerLabel!.font = UIFont(name: (countDownTimerLabel?.font.fontName)!, size: 40.0)
        countDownTimerLabel!.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
        countDownTimerLabel!.textAlignment = .center
        countDownTimerLabel!.layer.zPosition = 1
        countDownTimerLabel!.textColor = UIColor(red: 229.0/255.0, green: 126.0/255.0, blue: 38.0/255.0, alpha: 1)
        countDownTimerLabel?.backgroundColor = UIColor(red: 210.0/255.0, green: 215.0/255.0, blue: 211.0/255.0, alpha: 0.75)
        countDownTimerLabel?.layer.masksToBounds = true
        countDownTimerLabel!.layer.cornerRadius = (self.countDownTimerLabel?.frame.size.width)! / 2
        countDownTimerLabel!.isHidden = true
        self.view.addSubview(countDownTimerLabel!)

        
        // rotary selector //
        newRotarySelector = NewRotarySelector(view: self.view)
        newRotarySelector?.delegate = self
 
        
        // screen tap to dismiss the rotary view //
        let screenTap = UITapGestureRecognizer(target: self, action: #selector(tappedScreen))
        self.view.addGestureRecognizer(screenTap)
        
        
        // camera object //
        cameraObject = CameraObject(mainCameraView: self.view)
    }
    
    
    
    @objc func mainSwitchOnChange(_ sender: UISwitch) {
        if(sender.isOn){
            cameraObject?.startEyeTracking()
            eyeTrackingToggle = true
        }else{
            cameraObject?.stopEyeTracking()
            eyeTrackingToggle = false
        }
    }
    
    
    
    @objc func settingsButtonOnClick(){
        let settingsViewController = self.storyboard?.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    
    
    @objc func microphoneButtonOnClick(){
        let recordingViewController = self.storyboard?.instantiateViewController(withIdentifier: "Record") as! RecordingViewController
        self.navigationController?.pushViewController(recordingViewController, animated: true)
    }
    
    
    
    
    
    
    
    
    // **** rotary button stuff **** //
    // Center button taps //
    func centerButtonTap(open: Bool) {
    
        print("open? -> \(open)")
        
    }
    
    func centerButtonLongTap(beginEnd: Bool) {
        // will initiate sound and start doing the countdown timer/eye tracking //
        
        let soundsController:SoundsController = SoundsController()
        if(eyeTrackingToggle == false){
            if(beginEnd){
                if(selectedSound == "dog-1"){
                    soundsController.playSound(name: "bark")
                }else if(selectedSound == "cat"){
                    soundsController.playSound(name: "CatMeow1")
                }else if(selectedSound == "chicken"){
            
                }
            
                if(!eyeTrackingToggle){
                    self.startCountDownTimer()
                }
            }else{
                soundsController.stopSound()
                self.timer?.invalidate()
                self.countDownTimerLabel!.isHidden = true
            }
        }
    }
    

    // this is to let the rotary class know that there was a tap made and //
    // it should dismiss the view //
    @objc func tappedScreen(sender:UITapGestureRecognizer){
        self.dismissAllViews()
    }
    

    func dismissAllViews(){
        if(newRotarySelector != nil){
            newRotarySelector!.closeOutterCircle()
        }
    }
    
    
    
    
    
    

    // **** timer stuff **** //
    func startCountDownTimer(){
        timerCount = 6
        self.countDownTimerLabel!.isHidden = false
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            self.timerFire()
        })
        
        timer?.fire()
    }
    
    func timerFire(){
        timerCount = timerCount - 1
        self.countDownTimerLabel!.text = "\(timerCount)"
        if(timerCount == 0){
            timer?.invalidate()
            self.countDownTimerLabel!.isHidden = true
            
            // snap picture //
            cameraObject?.snapPicture()
        }
    }
   
}


