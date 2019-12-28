//
//  Created by @whichxjy.
//  Copyright © 2019 @whichxjy. All rights reserved.
//

import Foundation

class NoteDataSource: DataSource {
  
  var notes: [Note] {
    return [
      Note(content: "-1- SQLite is an open source, lightweight and cross platform relational database however it does require good knowledge of SQL to use. \nFor me that is not much of a problem however it is always better if we can avoid embedding SQL statements in our source code."),
      Note(content: "-2- SQLite is an open source, lightweight and cross platform relational database however it does require good knowledge of SQL to use. \nFor me that is not much of a problem however it is always better if we can avoid embedding SQL statements in our source code."),
      Note(content: "-3- SQLite is an open source, lightweight and cross platform relational database however it does require good knowledge of SQL to use. \nFor me that is not much of a problem however it is always better if we can avoid embedding SQL statements in our source code.")
    ]
  }
  
  init() {
    // load data
  }
  
  func store<T>(object: T) {
    guard let note = object as? Note else {
      return
    }
    
    // save note
    print(note.content)
    
    NotificationCenter.default.post(name: .noteDataChanged, object: nil)
  }
  
  func delete<T>(object: T) {
    guard let note = object as? Note else {
      return
    }
    
    // delete note
    print(note.content)

    NotificationCenter.default.post(name: .noteDataChanged, object: nil)
  }
  
}

extension Notification.Name {
  
  // notification for the change of note
  static let noteDataChanged = Notification.Name(rawValue: "noteDataChanged")
  
}
