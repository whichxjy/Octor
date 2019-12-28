//
//  Created by @whichxjy.
//  Copyright © 2019 @whichxjy. All rights reserved.
//  

import UIKit

class DisplayViewController: UIViewController {
  
  private var textView: UITextView!
  private var text: String!

  init(text: String?) {
    self.text = text
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
    // add text view
    addTextView()
  }
  
  private func addTextView() {
    textView = UITextView(frame: CGRect(x: 0, y: 50, width: 200, height: 200))
    textView.center.x = self.view.center.x
    textView.text = self.text
    self.view.addSubview(textView)
  }
  
}
