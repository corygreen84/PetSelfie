//
//  EyeTrackingObject.swift
//  PetSelfieAppTake3
//
//  Created by Cory Green on 3/10/19.
//  Copyright © 2019 Cory Green. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class EyeTrackingObject: NSObject, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var mainCameraView:UIView?
    var captureVideoDataOutput:AVCaptureVideoDataOutput?
    var captureSession:AVCaptureSession?
    
    
    private var detectionRequests: [VNDetectFaceRectanglesRequest]?
    private var trackingRequests: [VNTrackObjectRequest]?
    
    lazy var sequenceRequestHandler = VNSequenceRequestHandler()
    
    //var arrayOfRectangleObjects:[RectangleObject] = []
    var dictionaryOfRectangleObjects:[Int:RectangleObject] = [:]
    var redView:UIView?
    var reqCount = 0
    
    var staticDifference = 0
    var staticCount = 0
    
    init(mainCameraView:UIView, captureSession:AVCaptureSession) {
        super.init()
        self.mainCameraView = mainCameraView
        self.captureSession = captureSession
        self.prepareVisionRequest()
    }
    
    // prepare the vision request //
    func prepareVisionRequest(){
        var requests = [VNTrackObjectRequest]()
        let faceDetectionRequest = VNDetectFaceRectanglesRequest { (request, error) in
            
            if error != nil
            {
                print("FaceDetection error: \(String(describing: error)).")
            }
            guard let faceDetectionRequest = request as? VNDetectFaceRectanglesRequest,
                let results = faceDetectionRequest.results as? [VNFaceObservation] else{
                    return
                    
            }
            DispatchQueue.main.async {
                
                for observation in results{
                    let faceTrackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation)
                    requests.append(faceTrackingRequest)
                }
                self.trackingRequests = requests
            }
        }
        
        self.detectionRequests = [faceDetectionRequest]
        
        self.sequenceRequestHandler = VNSequenceRequestHandler()
    }
    
    
    // start scanning for eyes //
    func startScanningForEyes(){
        
        captureVideoDataOutput = AVCaptureVideoDataOutput()
        captureVideoDataOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: kCVPixelFormatType_32BGRA] as? [String : Any]
        
        let videoDataOutputQueue = DispatchQueue(label: "com.greenmachine.Pet-Selfie-Take-2")
        captureVideoDataOutput?.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        
        if captureSession!.canAddOutput(captureVideoDataOutput!) {
            captureSession!.addOutput(captureVideoDataOutput!)
        }
        
        captureVideoDataOutput!.connection(with: .video)?.isEnabled = true
        
        if let captureConnection = captureVideoDataOutput!.connection(with: AVMediaType.video) {
            if captureConnection.isCameraIntrinsicMatrixDeliverySupported {
                captureConnection.isCameraIntrinsicMatrixDeliveryEnabled = true
            }
        }
    }
    
    // stop scanning for eyes //
    func stopScanningForEyes(){
        if(captureSession != nil){
            DispatchQueue.main.async {

                for objects in self.dictionaryOfRectangleObjects{
                    objects.value.removeFromView()
                }
                self.dictionaryOfRectangleObjects.removeAll()
                // remove things from superview //
                
            }
            self.captureSession!.removeOutput(captureVideoDataOutput!)
        }
    }
    
    
    // converts sample buffer to UIImage //
    func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) ->UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        guard let cgImage = context.makeImage() else {
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation:.right)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
    }
    
    
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let outputImage = getImageFromSampleBuffer(sampleBuffer: sampleBuffer) else{
            return
        }
        
        let request = VNDetectFaceRectanglesRequest { (req, err) in
            
            if let err = err{
                print("failed to detect faces:", err)
                return
            }
            
            // need to do some cleanup here if there are no faces present //
            // removes the rectangle objects within the dictionary //
            self.reqCount = (req.results?.count)!
            if(self.reqCount == 0){
                self.staticCount = self.reqCount
                DispatchQueue.main.async {
                    for views in self.mainCameraView!.subviews{
                        if(views.tag == 100){
                            views.removeFromSuperview()
                        }
                    }
                    self.dictionaryOfRectangleObjects.removeAll()
                }
            }

            
            for(i, res) in (req.results?.enumerated())!{
                
                guard let faceObservation = res as? VNFaceObservation else{
                    return
                }
                
                DispatchQueue.main.async {
                    
                    // creates the number of faces present //
                    if(self.reqCount > RectangleObject.instanceCount){

                        if(self.dictionaryOfRectangleObjects[i] == nil){
                            let newRectObject:RectangleObject = RectangleObject(view: self.mainCameraView!, index: 100)
                            self.dictionaryOfRectangleObjects[i] = newRectObject
                        }
                
                    }else if(self.reqCount < RectangleObject.instanceCount){
                        
                        let difference = RectangleObject.instanceCount - self.reqCount
                        if(self.staticDifference != difference){
                            self.staticDifference = difference
                            
                            for views in self.mainCameraView!.subviews{
                                if(views.tag == 100){
                                    views.removeFromSuperview()
                                }
                            }
                            
                            for objects in self.dictionaryOfRectangleObjects{
                                objects.value.removeFromView()
                            }
                            self.dictionaryOfRectangleObjects.removeAll()

                        }
                        
                        
                
                    }

                    let affectedRectangleObject = self.dictionaryOfRectangleObjects[i]
                    let boundingBox = faceObservation.boundingBox
                    let size = CGSize(width: boundingBox.width * self.mainCameraView!.bounds.width,
                                      height: boundingBox.height * self.mainCameraView!.bounds.height)
                    let origin = CGPoint(x: boundingBox.minX * self.mainCameraView!.bounds.width,
                                         y: (1 - faceObservation.boundingBox.minY) * self.mainCameraView!.bounds.height - size.height)
                    
                    let rectFrame = CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
                    affectedRectangleObject?.updateLocation(frame: rectFrame)
                    
                }
            }
        }
        
        guard let cgImage = outputImage.cgImage else{
            return
        }
        
        // had to permanently change the orientation to be .leftMirrored for the face tracking to work properly //
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .leftMirrored, options: [:])
        
        do{
            try handler.perform([request])
        }catch let reqErr{
            print("failed to perform request:", reqErr)
        }
        
    }

}
