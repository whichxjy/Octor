//
//  Created by @whichxjy.
//  Copyright © 2019 @whichxjy. All rights reserved.
//  

import Foundation

protocol DataSource {
  
  func store<T>(object: T)
  func delete<T>(object: T)
  
}
