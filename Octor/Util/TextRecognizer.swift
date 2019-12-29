//
//  Created by @whichxjy.
//  Copyright © 2019 @whichxjy. All rights reserved.
//  

import TesseractOCR
import GPUImage

class TextRecognizer {
  
  private var tesseract: G8Tesseract!
  
  init() {
    tesseract = G8Tesseract(language: "eng+fra")
    tesseract?.engineMode = .tesseractCubeCombined
    tesseract?.pageSegmentationMode = .auto
  }
  
  func recognize(_ image: UIImage) -> String? {
    let scaledImage = image.scale(maxDimension: 1000) ?? image
    let preprocessedImage = scaledImage.preprocess() ?? scaledImage
    tesseract?.image = preprocessedImage
    tesseract?.recognize()
    return tesseract?.recognizedText
  }
}

// MARK: - UIImage Extension

extension UIImage {
  
  func scale(maxDimension: CGFloat) -> UIImage? {
    // keep the width-to-height ratio constant
    var targetSize = CGSize(width: maxDimension, height: maxDimension)
    if size.width > size.height {
      // keep width to maxDimension and update height
      targetSize.height = size.height / size.width * targetSize.width
    }
    else {
      // keep height to maxDimension and update width
      targetSize.width = size.width / size.height * targetSize.height
    }
    // draw a new image
    UIGraphicsBeginImageContext(targetSize)
    draw(in: CGRect(origin: .zero, size: targetSize))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return scaledImage
  }
  
  func preprocess() -> UIImage? {
    let stillImageFilter = GPUImageAdaptiveThresholdFilter()
    stillImageFilter.blurRadiusInPixels = 15.0
    let filteredImage = stillImageFilter.image(byFilteringImage: self)
    return filteredImage
  }
  
}
