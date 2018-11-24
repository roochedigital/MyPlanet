//  Created by rjcristy on 2018/8/29.

import Foundation

enum EOError: Error {
  case invalidURL(String)
  case invalidParameter(String, Any)
  case invalidJSON(String)
}
