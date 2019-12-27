//
//  Created by @whichxjy.
//  Copyright © 2019 @whichxjy. All rights reserved.
//  

import UIKit

class DisplayViewController: UIViewController {
  
  private var imageView: UIImageView!
  private var photo: UIImage!

  init(photo: UIImage) {
    self.photo = photo
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    // show top bar
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    // add image view
    addImageView()
  }
  
  private func addImageView() {
    imageView = UIImageView(frame: CGRect(x: 0, y: 50, width: 200, height: 200))
    imageView.center.x = self.view.center.x
    imageView.image = self.photo
    self.view.addSubview(imageView)
  }
  
}
