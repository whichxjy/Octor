//
//  Created by @whichxjy.
//  Copyright © 2019 @whichxjy. All rights reserved.
//

import UIKit
import AVKit
import Vision

class CameraViewController: UIViewController {
  
  private var textDetectionRequest: VNDetectTextRectanglesRequest!
  
  private var captureSession: AVCaptureSession!
  private var stillImageOutput: AVCapturePhotoOutput!
  private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
  
  private var takePhotoButton: UIButton!
  
  public weak var delegate: CameraPhotoDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "文字识别"
    setupBackButton()
    setupTextDetection()
    setupCamera()
    addTakePhotoButton()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.captureSession.stopRunning()
  }
  
  // MARK: - Back button
  
  func setupBackButton() {
    let backButton = UIBarButtonItem()
    backButton.title = "返回"
    self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
  }
  
  // MARK: - TextDetection
  
  func setupTextDetection() {
    textDetectionRequest = VNDetectTextRectanglesRequest(completionHandler: handleDetection)
    textDetectionRequest!.reportCharacterBoxes = true
  }
  
  private func handleDetection(request: VNRequest, error: Error?) {
    guard let detectionResults = request.results else {
      return
    }
    let textResults = detectionResults.map() {
      return $0 as? VNTextObservation
    }
    if textResults.isEmpty {
      return
    }
    DispatchQueue.main.async {
      // remove old rects
      self.view.layer.sublayers?.removeSubrange(2...)
      let viewWidth = self.view.frame.size.width
      let viewHeight = self.view.frame.size.height
      for region in textResults {
        guard let boxes = region?.characterBoxes else {
          return
        }
        // iter all boxes in current region
        var xMin = CGFloat.greatestFiniteMagnitude
        var xMax: CGFloat = 0
        var yMin = CGFloat.greatestFiniteMagnitude
        var yMax: CGFloat = 0
        for box in boxes {
          xMin = min(xMin, box.bottomLeft.x)
          xMax = max(xMax, box.bottomRight.x)
          yMin = min(yMin, box.bottomRight.y)
          yMax = max(yMax, box.topRight.y)
        }
        // position and size of the rect for current region
        let x = xMin * viewWidth
        let y = (1 - yMax) * viewHeight
        let width = (xMax - xMin) * viewWidth
        let height = (yMax - yMin) * viewHeight
        // draw a new rect for current region
        let layer = CALayer()
        layer.frame = CGRect(x: x, y: y, width: width, height: height)
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemTeal.cgColor
        self.view.layer.addSublayer(layer)
      }
      // set button to the front
      self.takePhotoButton.layer.zPosition = 1
    }
  }
  
  // MARK: - Camera
  
  func setupCamera() {
    captureSession = AVCaptureSession()
    captureSession.sessionPreset = .high
    
    guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
    guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
    
    if captureSession.canAddInput(input) {
      videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
      videoPreviewLayer.frame = view.frame
      videoPreviewLayer.videoGravity = .resize
      view.layer.addSublayer(videoPreviewLayer)
      // add input
      captureSession.addInput(input)
      // add image output
      stillImageOutput = AVCapturePhotoOutput()
      if captureSession.canAddOutput(stillImageOutput) {
        captureSession.addOutput(stillImageOutput)
      }
      // add video data output
      let videoDataOutput = AVCaptureVideoDataOutput()
      videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Buffer Queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
      if captureSession.canAddOutput(videoDataOutput) {
        captureSession.addOutput(videoDataOutput)
      }
      DispatchQueue.global(qos: .userInitiated).async {
        self.captureSession.startRunning()
      }
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
    takePhotoButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -1.5 * buttonDiameter).isActive = true
    takePhotoButton.widthAnchor.constraint(equalToConstant: buttonDiameter).isActive = true
    takePhotoButton.heightAnchor.constraint(equalToConstant: buttonDiameter).isActive = true
  }
  
  @objc func buttonAction(sender: UIButton!) {
    let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
    stillImageOutput.capturePhoto(with: settings, delegate: self)
  }
  
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    var imageRequestOptions = [VNImageOption: Any]()
    if let cameraData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
      imageRequestOptions[.cameraIntrinsics] = cameraData
    }
    let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: imageRequestOptions)
    try! imageRequestHandler.perform([textDetectionRequest!])
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
