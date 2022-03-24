//
//  ViewController.swift
//  Live Detector
//
//  Created by Mario Senatore on 24/03/22.
//

import UIKit
import CoreML
import Vision
import AVKit

class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {

    
    let labelIdentifier: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let capture = AVCaptureSession()
        capture.sessionPreset = .photo
        
        
        
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else{return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else{return}
        
        capture.addInput(input)
        capture.startRunning()
        
        
        
        
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: capture)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        
        
        let outputData = AVCaptureVideoDataOutput()
        outputData.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        capture.addOutput(outputData)
        
        setupIdentifierConfidenceLabel()

    }

    
    fileprivate func setupIdentifierConfidenceLabel(){
        view.addSubview(labelIdentifier)
        labelIdentifier.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        labelIdentifier.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        labelIdentifier.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        labelIdentifier.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else{return}
        
        //   Here you can add the most suitable model for you
        guard let model = try? VNCoreMLModel(for: Resnet50().model)else{return}
        
        let request = VNCoreMLRequest(model: model) { (finishRequest, error )in
         
            guard let results = finishRequest.results as?[VNClassificationObservation] else{return}
            guard let observassion = results.first else{return}
            
            print(observassion.identifier,observassion.confidence)
            
            DispatchQueue.main.async {
                self.labelIdentifier.text = "\(observassion.identifier) + \(observassion.confidence * 100)"
            }
            
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    
    

}

