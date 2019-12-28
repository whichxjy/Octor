//
//  Created by @whichxjy.
//  Copyright © 2019 @whichxjy. All rights reserved.
//  

import UIKit

class NoteDetailController: UIViewController {
  
  private var textView: UITextView!
  private var saveButton: UIBarButtonItem!
  private var trashButton: UIBarButtonItem!
  
  public var note: Note? = nil
  private let placeholder = "请输入文字..."
  
  private var originalContent: String = ""
  private var shouldDelete: Bool = false
  
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

    self.navigationItem.title = "修改"
    self.navigationItem.largeTitleDisplayMode = .never
    
    // init note
    if self.note == nil {
      self.note = Note(content: "")
    }
    // original content to show
    self.originalContent = self.note?.content ?? ""
    // subviews
    addSaveButton()
    addTrashButton()
    addTextView()
    // only trash button
    self.navigationItem.rightBarButtonItems = [trashButton]
  }
  
  // MARK: - Subviews
  
  func addSaveButton() {
    saveButton = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(didTapSave))
  }
  
  func addTrashButton() {
    trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDelete))
  }
  
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
    
    self.textView.text = self.note?.content.isEmpty == true ? self.placeholder : self.note?.content
    self.textView.delegate = self
    
    self.view.addSubview(self.textView)
    // layout
    textView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    textView.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
    textView.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
  }
  
  @objc func didTapSave() {
    self.textView.endEditing(true)
  }
  
  @objc func didTapDelete() {
    self.shouldDelete = true
    self.navigationController?.popViewController(animated: true)
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
    
    self.navigationItem.hidesBackButton = true
    
    // display trash button and save button
    if let trashButton = self.trashButton, let doneButton = self.saveButton {
      self.navigationItem.rightBarButtonItems = [doneButton, trashButton]
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = self.placeholder
    }
    
    self.note?.content = textView.text
    
    // display trash button
    if let trashButton = self.trashButton {
      self.navigationItem.rightBarButtonItems = [trashButton]
    }
    
    self.navigationItem.hidesBackButton = false
  }
  
}
