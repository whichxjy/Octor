//
//  Created by @whichxjy.
//  Copyright © 2019 @whichxjy. All rights reserved.
//

import Foundation

class Note {
  
  var id: String
  var content: String
  var lastEdited: Date
  
  init(id: String = UUID().uuidString, content: String, lastEdited: Date = Date()) {
    self.id = id
    self.content = content
    self.lastEdited = lastEdited
  }
  
}

// MARK: - Note Extension

extension Note: Writable {
  
  func write(dataSource: DataSource) {
    self.lastEdited = Date()
    dataSource.store(object: self)
  }
  
  func delete(dataSource: DataSource) {
    dataSource.delete(object: self)
  }
  
}

