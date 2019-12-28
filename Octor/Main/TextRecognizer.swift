//
//  Created by @whichxjy.
//  Copyright © 2019 @whichxjy. All rights reserved.
//  

import TesseractOCR

class TextRecognizer {
  
  func recognize(_ image: UIImage) {
    let scaledImage = image.scale(maxDimension: 1000) ?? image
    if let tesseract = G8Tesseract(language: "eng+fra") {
      tesseract.engineMode = .tesseractCubeCombined
      tesseract.pageSegmentationMode = .auto
      tesseract.image = scaledImage
      tesseract.recognize()
      print(tesseract.recognizedText)
    }
  }
}

// MARK: - UIImage extension

extension UIImage {
  
  func scale(maxDimension: CGFloat) -> UIImage? {
    // keep the width-to-height ratio constant
    var targetSize = CGSize(width: maxDimension, height: maxDimension)
    if size.width > size.height {
      // keep width to maxDimension and update height
      targetSize.height = size.height / size.width * targetSize.width;
    }
    else {
      // keep height to maxDimension and update width
      targetSize.width = size.width / size.height * targetSize.height;
    }
    // draw a new image
    UIGraphicsBeginImageContext(targetSize)
    draw(in: CGRect(origin: .zero, size: targetSize))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return scaledImage;
  }
  
}
