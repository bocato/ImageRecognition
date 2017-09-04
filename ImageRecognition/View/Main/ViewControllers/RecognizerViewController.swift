//
//  RecognizerViewController.swift
//  ImageRecognition
//
//  Created by Eduardo Sanches Bocato on 04/09/17.
//  Copyright © 2017 Bocato. All rights reserved.
//

import UIKit
import AVKit
import Vision

protocol RecognizerViewControllerDelegate {
    func didReceiveNewClassificationResults(_ classificationResults: [VNClassificationObservation]?)
}

private let videoQueueIdentifier = "videoQueue"

// TODO: Deal with error handling
class RecognizerViewController: UIViewController {
    
    // MARK: - Properties
    var delegate: RecognizerViewControllerDelegate?
    var captureSession: AVCaptureSession!
    var classifications: [VNClassificationObservation]?
    var bestResultFromLastObservation: VNClassificationObservation?
    var minimumConfidence: Float = 0.01
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAVCaptureSession()
        configureAVCaptureVideoPreviewLayer()
        configureAVCaptureVideoDataOutput()
    }
    
    // MARK: - Configuration
    func configureAVCaptureSession() {
        
        captureSession = AVCaptureSession()
        //        captureSession.sessionPreset =  .photo // this configures the view with some kind of borders
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(captureDeviceInput)
        
        captureSession.startRunning() // Move it to another place... Action?
    }
    
    func configureAVCaptureVideoPreviewLayer() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
    }
    
    func configureAVCaptureVideoDataOutput() {
        let captureVideoDataOutput = AVCaptureVideoDataOutput()
        captureVideoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: videoQueueIdentifier))
        captureSession.addOutput(captureVideoDataOutput)
    }
    
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension RecognizerViewController : AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        
        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            
            guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
            
            guard let bestResultFromThisObservation = results.first else { return }
            
//            debugPrint("Possible Object: \(bestResultFromThisObservation.identifier) - Confidence: \(String(format: "%.2f", bestResultFromThisObservation.confidence))")
            
            if bestResultFromThisObservation.confidence >= self.minimumConfidence {
                
                if self.bestResultFromLastObservation == nil {
                    self.bestResultFromLastObservation = bestResultFromThisObservation
                }
                
                if bestResultFromThisObservation.confidence >= self.bestResultFromLastObservation!.confidence {
                    
                    DispatchQueue.main.async {
                        self.classifications = results
                        let top5 = Array(self.classifications!.prefix(5))
                        self.delegate?.didReceiveNewClassificationResults(top5)
                    }
                    
                }
                
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }
    
}