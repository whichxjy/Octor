//
//  Created by @whichxjy.
//  Copyright © 2019 @whichxjy. All rights reserved.
//

import Foundation
import SQLite

class NoteDataSource: DataSource {
  
  private var db: Connection!
  
  // table
  private let noteTable = Table("notes")
  private let id = Expression<String>("id")
  private let content = Expression<String>("content")
  private let lastEdited = Expression<Date>("lastEdited")
  
  var notes: [Note] {
    // get all notes from db
    var noteList: [Note] = []
    for note in try! db.prepare(noteTable.order(lastEdited.desc)) {
      noteList.append(Note(id: note[id], content: note[content], lastEdited: note[lastEdited]))
    }
    return noteList
  }
  
  init() {
    let path = NSSearchPathForDirectoriesInDomains(
      .documentDirectory, .userDomainMask, true
    ).first!
    db = try! Connection("\(path)/db.sqlite3")
    
    // create table
    _ = try? db.run(noteTable.create(temporary: false) { t in
      t.column(id, primaryKey: true)
      t.column(content)
      t.column(lastEdited)
    })
  }
  
  func store<T>(object: T) {
    guard let note = object as? Note else {
      return
    }
    
    // save note
    let insert = noteTable.insert(or: .replace, id <- note.id, content <- note.content, lastEdited <- note.lastEdited)
    try! db.run(insert)
    
    NotificationCenter.default.post(name: .noteDataChanged, object: nil)
  }
  
  func delete<T>(object: T) {
    guard let note = object as? Note else {
      return
    }
    
    // delete note
    let targetNote = noteTable.filter(id == note.id)
    try! db.run(targetNote.delete())
    
    NotificationCenter.default.post(name: .noteDataChanged, object: nil)
  }
  
}

extension Notification.Name {
  
  static let noteDataChanged = Notification.Name(rawValue: "noteDataChanged")
  
}

