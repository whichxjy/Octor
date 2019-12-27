//
//  Created by @whichxjy.
//  Copyright © 2019 @whichxjy. All rights reserved.
//

import UIKit
import MobileCoreServices

class HomeViewController: UIViewController {
  
  private var photoLibraryButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    // hide top bar
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    // add photo library button
    addPhotoLibraryButton()
  }
  
  private func addPhotoLibraryButton() {
    photoLibraryButton = UIButton(frame: CGRect(x: 0, y: 100, width: 100, height: 50))
    photoLibraryButton.center.x = self.view.center.x
    photoLibraryButton.backgroundColor = .blue
    photoLibraryButton.setTitle("从相册选择", for: .normal)
    photoLibraryButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    self.view.addSubview(photoLibraryButton)
  }
  
  @objc private func buttonAction(sender: UIButton!) {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = .photoLibrary
    imagePicker.mediaTypes = [kUTTypeImage as String]
    self.present(imagePicker, animated: true)
  }
}

// MARK: - UINavigationControllerDelegate
extension HomeViewController: UINavigationControllerDelegate {
  // empty
}

// MARK: - UIImagePickerControllerDelegate
extension HomeViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let selectedPhoto = info[.originalImage] as? UIImage else {
      dismiss(animated: true)
      return
    }
    
    dismiss(animated: true) {
      // display image
      self.navigationController?.pushViewController(DisplayViewController(photo: selectedPhoto), animated: true)
    }
  }
}


