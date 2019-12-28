//
//  Created by @whichxjy.
//  Copyright © 2019 @whichxjy. All rights reserved.
//

import Foundation

class Note {
  
  var identifier: String
  var content: String
  var lastEdited: Date
  
  init(identifier: String = UUID().uuidString, content: String, lastEdited: Date = Date()) {
    self.identifier = identifier
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

