//
//  CameraObject.swift
//  PetSelfieAppTake3
//
//  Created by Cory Green on 3/27/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class CameraObject: NSObject, AVCapturePhotoCaptureDelegate {

    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var capturePhotoOutput:AVCapturePhotoOutput?
    
    var mainCameraView:UIView?
    
    var eyeTracking:EyeTrackingObject?
    
    var pictureTaken = false
    
    init(mainCameraView:UIView) {
        super.init()
        
        self.mainCameraView = mainCameraView
        
        self.cameraSetup()
    }
    
    func cameraSetup(){
        
        // camera setup //
        let captureDevice = AVCaptureDevice.default(.builtInTrueDepthCamera, for: AVMediaType.video, position: AVCaptureDevice.Position.front)
        
        do{
            let _input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(_input)
        }catch{
            print(error)
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = self.mainCameraView!.bounds
        mainCameraView?.layer.addSublayer(videoPreviewLayer!)
        
        self.captureSession?.startRunning()
        
        // getting an instance of ACCapturePhotoOutput class //
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput?.isHighResolutionCaptureEnabled = true
        
        captureSession?.addOutput(capturePhotoOutput!)
        
        eyeTracking = EyeTrackingObject(mainCameraView: self.mainCameraView!, captureSession: captureSession!)
        
    }
    
    // **** snap picture stuff **** //
    func snapPicture() {
        if(self.pictureTaken == false){
            self.pictureTaken = true
            guard let capturePhotoOutput = self.capturePhotoOutput else{
                return
            }
            
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.isAutoStillImageStabilizationEnabled = true
            photoSettings.isHighResolutionPhotoEnabled = true
            photoSettings.flashMode = .on
            
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let imageData = photo.fileDataRepresentation()
        let capturedImage = UIImage(data: imageData!, scale: 1.0)
        if let image = capturedImage{
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    
    func startEyeTracking(){
        eyeTracking?.startScanningForEyes()
    }
    
    func stopEyeTracking(){
        eyeTracking?.stopScanningForEyes()
    }
    
}
