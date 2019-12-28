//
//  Created by @whichxjy.
//  Copyright © 2019 @whichxjy. All rights reserved.
//

import UIKit

class NoteTableCell: UITableViewCell {
  
  static let cellID = "NoteTableCell"
  
  private var customBackgroundView: UIView!
  private var titleLabel: UILabel!
  private var subtitleLabel: UILabel!
  
  public var note: Note? = nil {
    didSet {
      // set note of current cell
      guard let note = note else {
        return
      }
      // set title
      self.titleLabel.text = String(note.content.split(separator: "\n")[0])
      // set subtitle with date
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .short
      self.subtitleLabel.text = "Edited on \(formatter.string(from: note.lastEdited))"
    }
  }
  
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.accessibilityTraits = UIAccessibilityTraits.button
    self.backgroundColor = UIColor.clear
    self.selectionStyle = .none
    // add subviews
    addCustomBackgroundView()
    addTitleLabel()
    addSubtitleLabel()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Subviews
  
  func addCustomBackgroundView() {
    customBackgroundView = UIView()
    customBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    customBackgroundView.backgroundColor = UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1.0)
    customBackgroundView.layer.cornerRadius = 10
    customBackgroundView.clipsToBounds = true
    self.contentView.addSubview(customBackgroundView)
  }
  
  func addTitleLabel() {
    titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
    titleLabel.adjustsFontForContentSizeCategory = true
    titleLabel.textColor = UIColor.white
    titleLabel.numberOfLines = 1
    self.contentView.addSubview(titleLabel)
  }
  
  func addSubtitleLabel() {
    subtitleLabel = UILabel()
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    subtitleLabel.adjustsFontForContentSizeCategory = true
    subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
    subtitleLabel.numberOfLines = 0
    self.contentView.addSubview(subtitleLabel)
  }
  
  override func layoutSubviews() {
    self.customBackgroundView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4).isActive = true
    self.customBackgroundView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4).isActive = true
    self.customBackgroundView.leadingAnchor.constraint(equalTo: self.contentView.readableContentGuide.leadingAnchor).isActive = true
    self.customBackgroundView.trailingAnchor.constraint(equalTo: self.contentView.readableContentGuide.trailingAnchor).isActive = true
    
    self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20).isActive = true
    self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.readableContentGuide.leadingAnchor, constant: 10).isActive = true
    self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.readableContentGuide.trailingAnchor).isActive = true
    
    self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor).isActive = true
    self.subtitleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
    self.subtitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor).isActive = true
    self.subtitleLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor).isActive = true
  }
  
}

