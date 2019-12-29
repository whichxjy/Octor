//
//  Created by @whichxjy.
//  Copyright © 2019 @whichxjy. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {
  
  private var notesTableView: UITableView!
  private var noteDataSource: NoteDataSource
  private var notes: [Note] {
    return self.noteDataSource.notes
  }
  
  init(noteDataSource: NoteDataSource) {
    self.noteDataSource = noteDataSource
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewDidLoad() {
    initNavigationController()
    addNotesTableView()
    // observe notes' change
    NotificationCenter.default.addObserver(self, selector: #selector(notesDidUpdate), name: .noteDataChanged, object: nil)
  }
  
  // MARK: - Subviews
  
  func initNavigationController() {
    self.navigationController?.navigationBar.barStyle = .black
    self.navigationController?.navigationBar.tintColor = .white
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationItem.largeTitleDisplayMode = .automatic
    self.navigationItem.title = "全部笔记"
    // add compose button
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapCompose))
  }
  
  func addNotesTableView() {
    notesTableView = UITableView()
    notesTableView.translatesAutoresizingMaskIntoConstraints = false
    notesTableView.backgroundColor = UIColor.clear
    notesTableView.separatorStyle = .none
    
    notesTableView.dataSource = self
    notesTableView.delegate = self
    
    notesTableView.rowHeight = UITableView.automaticDimension
    notesTableView.estimatedRowHeight = CGFloat(50)
    
    notesTableView.register(NoteTableCell.self, forCellReuseIdentifier: NoteTableCell.cellID)
    self.view.addSubview(notesTableView)
    
    // layout
    notesTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
    notesTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    notesTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
    notesTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
  }
  
  @objc func didTapCompose() {
    self.navigationController?.pushViewController(NoteDetailController(noteDataSource: self.noteDataSource), animated: true)
  }
  
  @objc func notesDidUpdate() {
    notesTableView.reloadData()
  }
}

// MARK: - UITableViewDataSource

extension NotesViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableCell.cellID, for: indexPath) as! NoteTableCell
    cell.note = self.notes[indexPath.row]
    cell.layoutIfNeeded()
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.notes.count
  }
  
}

// MARK: - UITableViewDelegate

extension NotesViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let noteDetailController = NoteDetailController(noteDataSource: self.noteDataSource)
    noteDetailController.note = self.notes[indexPath.row]
    self.navigationController?.pushViewController(noteDetailController, animated: true)
  }
  
}

