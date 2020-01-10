//
//  RecusiveTests.swift
//  DipTests
//
//  Created by John Twigg on 1/9/20.
//  Copyright © 2020 AliSoftware. All rights reserved.
//

import XCTest
@testable import Dip


class RecusiveTests: XCTestCase {

  
  fileprivate class ServiceC {
    init(_ serviceA: ServiceA) {
      
    }
  }
  fileprivate class ServiceB {
    init(_ servicec: ServiceC) {
         
       }
  }
  fileprivate class ServiceA {
    init(_ serviceB: ServiceB) {
    }
  }
  
  fileprivate class ServiceRoot {
    init(_ serviceA: ServiceA) {
    }
  }
  
  
    func testRecuriveDepthReached() {
        let container = DependencyContainer()
      
      container.register { (serviceA: ServiceA ) -> ServiceRoot in
             return ServiceRoot.init(serviceA)
      }
      
      container.register { (serviceB: ServiceB ) -> ServiceA in
        return ServiceA.init(serviceB)
      }
      
      container.register { (serviceC: ServiceC ) -> ServiceB in
        return ServiceB.init(serviceC)
      }
      
      container.register { (serviceA: ServiceA ) -> ServiceC in
             return ServiceC.init(serviceA)
        }
      
      do {
        let _ : ServiceRoot = try container.resolve()
        XCTFail()
      } catch {
        switch error {
        case let dipError as DipError:
          XCTAssert(dipError.isRecusiveError)
          
          guard let report = dipError.analyzeRecursiveError() else {
            XCTFail()
            return
          }
          print(report)
        default:
          XCTFail()
        }
      }
    }

}
