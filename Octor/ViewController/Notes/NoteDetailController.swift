//
//  Created by @whichxjy.
//  Copyright © 2019 @whichxjy. All rights reserved.
//

import UIKit
import MobileCoreServices

class NoteDetailController: UIViewController {
  
  private var textView: UITextView!
  private var shareButton: UIBarButtonItem!
  private var trashButton: UIBarButtonItem!
  private var cameraButton: UIBarButtonItem!
  
  private lazy var imagePicker: UIImagePickerController = {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    imagePicker.mediaTypes = [kUTTypeImage as String]
    return imagePicker
  }()
  
  private lazy var textRecognizer: TextRecognizer = TextRecognizer()
  
  public var note: Note? = nil
  private let placeholder = ""
  
  private var originalContent: String = ""
  private var shouldDelete: Bool = false
  
  private lazy var ocrAlertController: UIAlertController = {
    let alert = UIAlertController(title: "文字识别", message: nil, preferredStyle: .actionSheet)
    // camera photo
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      alert.addAction(UIAlertAction(title: "拍照", style: .default) { (alert) -> Void in
        let cameraViewController = CameraViewController()
        cameraViewController.delegate = self
        self.navigationController?.pushViewController(cameraViewController, animated: true)
      })
    }
    // photo library
    alert.addAction(UIAlertAction(title: "从相册中添加", style: .default) { (alert) -> Void in
      self.present(self.imagePicker, animated: true)
    })
    return alert
  }()
  
  private lazy var failAlertController: UIAlertController = {
    let alert = UIAlertController(title: "识别不到文字", message: "请上传包含清晰文字的图片", preferredStyle: .alert)
    // fail to recognize
    alert.addAction(UIAlertAction(title: "返回", style: .default))
    return alert
  }()
  
  private let noteDataSource: NoteDataSource
  
  init(noteDataSource: NoteDataSource) {
    self.noteDataSource = noteDataSource
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    self.view.backgroundColor = .black
    self.view.backgroundColor = Theme.backgroundColor
    self.navigationItem.largeTitleDisplayMode = .never
    
    // init note
    if self.note == nil {
      self.note = Note(content: "")
    }
    
    // original content to show
    self.originalContent = self.note?.content ?? ""
    // subviews
    setupBackButton()
    addShareButton()
    addCameraButton()
    addTrashButton()
    addTextView()
    // display camera button trash button
    self.navigationItem.rightBarButtonItems = [trashButton, cameraButton, shareButton]
    // show keyboard
    textView.becomeFirstResponder()
  }
  
  // MARK: - Back Button
  
  func setupBackButton() {
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(saveAndExit))
  }
  
  @objc func saveAndExit() {
    self.textView.endEditing(true)
    self.navigationController?.popViewController(animated: true)
  }
  
  // MARK: - Share Button
  
  func addShareButton() {
    shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
  }
  
  @objc func didTapShare() {
    let activityViewController = UIActivityViewController(activityItems: [textView.text!], applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = self.view
    present(activityViewController, animated: true)
  }
  
  // MARK: - Camera Button
  
  func addCameraButton() {
    cameraButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(didTapCamera))
  }
  
  @objc func didTapCamera() {
    present(ocrAlertController, animated: true)
  }
  
  // MARK: - Trash Button
  
  func addTrashButton() {
    trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDelete))
  }
  
  @objc func didTapDelete() {
    self.shouldDelete = true
    self.navigationController?.popViewController(animated: true)
  }
  
  // MARK: - Text View
  
  func addTextView() {
    textView = UITextView()
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.font = UIFont.preferredFont(forTextStyle: .headline)
    textView.adjustsFontForContentSizeCategory = true
    textView.textColor = UIColor.white
    textView.text = "..."
    textView.textAlignment = .left
    textView.isScrollEnabled = true
    textView.backgroundColor = UIColor.clear
    textView.dataDetectorTypes = .all
    textView.text = self.note?.content.isEmpty == true ? self.placeholder : self.note?.content
    textView.delegate = self
    self.view.addSubview(self.textView)
    // layout
    textView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    textView.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
    textView.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    if self.textView.text.isEmpty || self.shouldDelete {
      self.note?.delete(dataSource: self.noteDataSource)
    }
    else {
      // check if the content has changed
      guard self.originalContent != self.note?.content else {
        return
      }
      self.note?.write(dataSource: self.noteDataSource)
    }
  }
  
}

// MARK: - UITextViewDelegate

extension NoteDetailController: UITextViewDelegate {
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == self.placeholder {
      textView.text = ""
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = self.placeholder
    }
    self.note?.content = textView.text
  }
  
  func recognizeAndAppend(image: UIImage) {
    let resultText = self.textRecognizer.recognize(image)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    // check if the result text is empty
    if (resultText.filter { !$0.isNewline && !$0.isWhitespace } == "") {
      self.present(self.failAlertController, animated: true, completion: nil)
    }
    else {
      // append result text to the content of current note
      self.textView.text.append(resultText)
    }
    textView.becomeFirstResponder()
  }
  
}

// MARK: - UINavigationControllerDelegate

extension NoteDetailController: UINavigationControllerDelegate {
  // empty
}

// MARK: - UIImagePickerControllerDelegate

extension NoteDetailController: UIImagePickerControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let selectedPhoto = info[.originalImage] as? UIImage else {
      dismiss(animated: true)
      return
    }
    
    dismiss(animated: true) {
      self.recognizeAndAppend(image: selectedPhoto)
    }
  }
  
}

// MARK: - CameraPhotoDelegate

extension NoteDetailController: CameraPhotoDelegate {
  
  func onCameraPhotoReady(image: UIImage) {
    self.recognizeAndAppend(image: image)
  }
  
}
