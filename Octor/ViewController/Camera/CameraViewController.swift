//
//  Created by @whichxjy.
//  Copyright © 2019 @whichxjy. All rights reserved.
//

import UIKit
import AVKit

class CameraViewController: UIViewController {
  
  private var takePhotoButton: UIButton!
  
  private var captureSession: AVCaptureSession!
  private var stillImageOutput: AVCapturePhotoOutput!
  private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
  
  public weak var delegate: CameraPhotoDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.topItem?.title = "返回"
    setupCamera()
    addTakePhotoButton()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.captureSession.stopRunning()
  }
  
  // MARK: - Camera
  
  func setupCamera() {
    captureSession = AVCaptureSession()
    captureSession.sessionPreset = .high
    
    guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
    guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
    
    stillImageOutput = AVCapturePhotoOutput()
    
    if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
      captureSession.addInput(input)
      captureSession.addOutput(stillImageOutput)
      videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
      view.layer.addSublayer(videoPreviewLayer)
      captureSession.startRunning()
      videoPreviewLayer.frame = view.frame
    }
  }
  
  // MARK: - TakePhotoButton
  
  func addTakePhotoButton() {
    let buttonDiameter = CGFloat(50)
    takePhotoButton = UIButton()
    takePhotoButton.translatesAutoresizingMaskIntoConstraints = false
    takePhotoButton.backgroundColor = .white
    takePhotoButton.layer.cornerRadius = buttonDiameter / 2
    takePhotoButton.clipsToBounds = true
    takePhotoButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    
    self.view.addSubview(takePhotoButton)
    
    // layout
    takePhotoButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    takePhotoButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -2 * buttonDiameter).isActive = true
    takePhotoButton.widthAnchor.constraint(equalToConstant: buttonDiameter).isActive = true
    takePhotoButton.heightAnchor.constraint(equalToConstant: buttonDiameter).isActive = true
  }
  
  @objc func buttonAction(sender: UIButton!) {
    let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
    stillImageOutput.capturePhoto(with: settings, delegate: self)
  }
  
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraViewController: AVCapturePhotoCaptureDelegate {
  
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    guard let imageData = photo.fileDataRepresentation() else { return }
    let image: UIImage! = UIImage(data: imageData)
    
    let photoAlertController = UIAlertController(title: "当前图片", message: nil, preferredStyle: .alert)
    photoAlertController.addImage(image: image)
    photoAlertController.addAction(UIAlertAction(title: "识别文字", style: .default) { (alert) -> Void in
      self.delegate?.onCameraPhotoReady(image: image)
      self.navigationController?.popViewController(animated: true)
    })
    photoAlertController.addAction(UIAlertAction(title: "重新选择", style: .default, handler: nil))
    photoAlertController.addAction(UIAlertAction(title: "丢弃", style: .cancel) { (alert) -> Void in
      self.navigationController?.popViewController(animated: true)
    })
    
    present(photoAlertController, animated: true)
  }
  
}

// MARK: - UIAlertController Extension

extension UIAlertController {
  
  func addImage(image: UIImage) {
    let imageAction = UIAlertAction(title: "", style: .default)
    imageAction.isEnabled = false
    
    let maxSize = CGSize(width: 245, height: 300)
    var scaledImage: UIImage! = image.scale(maxSize: maxSize)
    
    if image.size.height > image.size.width {
      // center the image
      let left = (maxSize.width - scaledImage.size.width) / 2
      scaledImage = scaledImage?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -left, bottom: 0, right: 0))
    }
    
    imageAction.setValue(scaledImage.withRenderingMode(.alwaysOriginal), forKey: "image")
    self.addAction(imageAction)
  }
  
}

// MARK: - UIImage Extension

extension UIImage {
  
  func scale(maxSize: CGSize) -> UIImage? {
    var ratio: CGFloat!
    if size.width > size.height {
      ratio = maxSize.width / size.width
    }
    else {
      ratio = maxSize.height / size.height
    }
    let targetSize = CGSize(width: size.width * ratio, height: size.height * ratio)
    // draw a new image
    UIGraphicsBeginImageContext(targetSize)
    draw(in: CGRect(origin: .zero, size: targetSize))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return scaledImage
  }
  
}
