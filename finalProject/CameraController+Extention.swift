//
//  CameraController+Extention.swift
//  finalProject
//
//  Created by Ильяр Мнаждин on 5/6/17.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import AVFoundation
import UIKit

extension CameraController : AVCapturePhotoCaptureDelegate {
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer!) else { return }
        let previewImage = UIImage(data: imageData) 
        
        let containerView = PreviewPhotoContainerView()
        containerView.previewImageView.image = previewImage
        
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        print("Finished processing photo sample buffer...")
    }
}
