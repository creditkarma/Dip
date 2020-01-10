//
// Dip
//
// Copyright (c) 2015 Olivier Halligon <olivier@halligon.net>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

/**
 Errors thrown by `DependencyContainer`'s methods.
 
 - seealso: `resolve(tag:)`
 */
public enum DipError: Error, CustomStringConvertible {
  
  /**
   Thrown when max reecursion depth is occured. You may have a recursive dependency.
   
   - parameter key: definition key attempted when limit was his
   */
  case recursionDepthReached(key: DefinitionKey)
  
  /**
   Thrown by `resolve(tag:)` if no matching definition was registered in container.
   
   - parameter key: definition key used to lookup matching definition
   */
  case definitionNotFound(key: DefinitionKey)
  
  /**
   Thrown by `resolve(tag:)` if failed to auto-inject required property.
   
   - parameters:
      - label: The name of the property
      - type: The type of the property
      - underlyingError: The error that caused auto-injection to fail
   */
  case autoInjectionFailed(label: String?, type: Any.Type, underlyingError: Error)
  
  /**
   Thrown by `resolve(tag:)` if failed to auto-wire a type.
   
   - parameters:
      - type: The type that failed to be resolved by auto-wiring
      - underlyingError: The error that cause auto-wiring to fail
   */
  case autoWiringFailed(type: Any.Type, underlyingError: Error)
  
  /**
   Thrown when auto-wiring type if several definitions with the same number of runtime arguments
   are registered for that type.
   
   - parameters:
      - type: The type that failed to be resolved by auto-wiring
      - definitions: Ambiguous definitions
   */
  case ambiguousDefinitions(type: Any.Type, definitions: [DefinitionType])
  
  /**
   Thrown by `resolve(tag:)` if resolved instance does not implemenet resolved type (i.e. when type-forwarding).
   
   - parameters:
      - resolved: Resolved instance
      - key: Definition key used to resolve instance
   */
  case invalidType(resolved: Any?, key: DefinitionKey)
  
  public var description: String {
    switch self {
    case let .recursionDepthReached(key: key):
      return "Max recusion depth reached:\(key)"
    case let .definitionNotFound(key):
      return "No definition registered for \(key).\nCheck the tag, type you try to resolve, number, order and types of runtime arguments passed to `resolve()` and match them with registered factories for type \(key.type)."
    case let .autoInjectionFailed(label, type, error):
      return "Failed to auto-inject property \"\(label.desc)\" of type \(type). \(error)"
    case let .autoWiringFailed(type, error):
      return "Failed to auto-wire type \"\(type)\". \(error)"
    case let .ambiguousDefinitions(type, definitions):
      return "Ambiguous definitions for \(type):\n" +
        definitions.map({ "\($0)" }).joined(separator: ";\n")
    case let .invalidType(resolved, key):
      return "Resolved instance \(resolved ?? "nil") does not implement expected type \(key.type)."
    }
  }
}

extension DipError {
  
  /// Informs you if the resolve failed because recursive limit was reached. Warning: O(n) for depth. May be slow
  public var isRecursiveError: Bool {
    switch self {
      case let .autoWiringFailed(type: _, underlyingError: underlyingError):
        if let dipError = underlyingError as? DipError {
          return dipError.isRecursiveError
        }
        return false
      case .recursionDepthReached:
        return true
      default:
        return false
    }
  }
  
  public struct RecursiveErrorReport: CustomStringConvertible {
    //The enture resolve stack that resulted in the recursive depth error
    public let resolveStack: [Any.Type]
    
    //The sub stack that was identified as a cycle, if any.
    public let cycleSubStack: [Any.Type]
    
    public var description: String {
      if cycleSubStack.count > 0 {
        return "Recursive Depth exceeded: Cycle Found: \(cycleSubStack)"
      }
      return "Recursive Depth exceeded. No cycle found (inconclusive). Full stack: \(resolveStack)"
    }
  }
  
  public func analyzeRecursiveError() -> RecursiveErrorReport? {
    guard isRecursiveError else {
      return nil
    }
    
    var resolveStack = [Any.Type]()
    
    func buildStack(error: DipError) {
      switch error {
        case let .autoWiringFailed(type: type, underlyingError: underlyingError):
          resolveStack.append(type)
          if let dipError = underlyingError as? DipError {
              buildStack(error: dipError)
          }
          return
        default:
          return
      }
    }
    
    buildStack(error: self)
    
    //Search for cycle subStack
    var cycleSubStack = [Any.Type]()
    var hitCount = [String:Int]()
    for (index, element) in resolveStack.enumerated() {
      let entryText = String(reflecting: element)
      let hit = (hitCount[entryText] ?? 0) + 1
      if hit == 2 {
        guard let last = resolveStack[0..<index].lastIndex(where: { (type) -> Bool in
                   return String(reflecting: type) == entryText
          }) else {
          break
        }
        
        cycleSubStack = Array(resolveStack[last..<index])
        break
      }
      hitCount[entryText] = hit
    }
    
    return RecursiveErrorReport.init(resolveStack: resolveStack,
                                    cycleSubStack: cycleSubStack)
  }
}

