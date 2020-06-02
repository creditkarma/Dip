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

import XCTest
@testable import Dip

private protocol Service: class { }
private class ServiceImp1: Service { }
private class ServiceImp2: Service { }
private class ServiceImp3 {}

private protocol AutoWiredClient: class {
  var service1: Service! { get set }
  var service2: Service! { get set }
}

private class AutoWiredClientImp: AutoWiredClient {
  var service1: Service!
  var service2: Service!
  
  init(service1: Service?, service2: ServiceImp2) {
    self.service1 = service1
    self.service2 = service2
  }
  init() {}
}

class AutoWiringTests: XCTestCase {
  
  let container = DependencyContainer()

  static var allTests = {
    return [
      ("testThatItCanResolveWithAutoWiring", testThatItCanResolveWithAutoWiring),
      ("testThatItUsesAutoWireFactoryWithMostNumberOfArguments", testThatItUsesAutoWireFactoryWithMostNumberOfArguments),
      ("testThatItThrowsAmbiguityErrorWhenUsingAutoWire", testThatItThrowsAmbiguityErrorWhenUsingAutoWire),
      ("testThatItUsesAutoWireFactoryWithMostNumberOfArguments", testThatItUsesAutoWireFactoryWithMostNumberOfArguments),
      ("testThatItPrefersTaggedFactoryWithDifferentNumberOfArgumentsWhenUsingAutoWire", testThatItPrefersTaggedFactoryWithDifferentNumberOfArgumentsWhenUsingAutoWire),
      ("testThatItPrefersTaggedFactoryWithDifferentTypesOfArgumentsWhenUsingAutoWire", testThatItPrefersTaggedFactoryWithDifferentTypesOfArgumentsWhenUsingAutoWire),
      ("testThatItFallbackToNotTaggedFactoryWhenUsingAutoWire", testThatItFallbackToNotTaggedFactoryWhenUsingAutoWire),
      ("testThatItDoesNotTryToUseAutoWiringWhenCallingResolveWithArguments", testThatItDoesNotTryToUseAutoWiringWhenCallingResolveWithArguments),
      ("testThatItDoesNotUseAutoWiringWhenFailedToResolveLowLevelDependency", testThatItDoesNotUseAutoWiringWhenFailedToResolveLowLevelDependency),
      ("testThatItReusesInstancesResolvedWithAutoWiringWhenUsingAutoWiringAgain", testThatItReusesInstancesResolvedWithAutoWiringWhenUsingAutoWiringAgain),
      ("testThatItReusesInstancesResolvedWithAutoWiringWhenUsingAutoWiringAgainWithTheSameTag", testThatItReusesInstancesResolvedWithAutoWiringWhenUsingAutoWiringAgainWithTheSameTag),
      ("testThatItDoesNotReuseInstancesResolvedWithAutoWiringWhenUsingAutoWiringAgainWithAnotherTag", testThatItDoesNotReuseInstancesResolvedWithAutoWiringWhenUsingAutoWiringAgainWithAnotherTag),
      ("testThatItUsesTagToResolveDependenciesWithAutoWiringWith1Argument", testThatItUsesTagToResolveDependenciesWithAutoWiringWith1Argument),
      ("testThatItUsesTagToResolveDependenciesWithAutoWiringWith2Arguments", testThatItUsesTagToResolveDependenciesWithAutoWiringWith2Arguments),
      ("testThatItUsesTagToResolveDependenciesWithAutoWiringWith3Arguments", testThatItUsesTagToResolveDependenciesWithAutoWiringWith3Arguments),
      ("testThatItUsesTagToResolveDependenciesWithAutoWiringWith4Arguments", testThatItUsesTagToResolveDependenciesWithAutoWiringWith4Arguments),
      ("testThatItUsesTagToResolveDependenciesWithAutoWiringWith5Arguments", testThatItUsesTagToResolveDependenciesWithAutoWiringWith5Arguments),
      ("testThatItUsesTagToResolveDependenciesWithAutoWiringWith6Arguments", testThatItUsesTagToResolveDependenciesWithAutoWiringWith6Arguments),
      ("testThatItCanAutoWireOptional", testThatItCanAutoWireOptional)
    ]
  }()

  override func setUp() {
    container.reset()
  }

  func testThatItCanResolveWithAutoWiring() {
    //given
    container.register { ServiceImp1() as Service }
    container.register { ServiceImp2() }
    
    container.register { AutoWiredClientImp(service1: $0, service2: $1) as AutoWiredClient }
    
    //when
    let client = try! container.resolve() as AutoWiredClient
    
    //then
    let service1 = client.service1
    XCTAssertTrue(service1 is ServiceImp1)
    let service2 = client.service2
    XCTAssertTrue(service2 is ServiceImp2)
    
    //when
    let anyClient = try! container.resolve(AutoWiredClient.self)
    
    //then
    XCTAssertTrue(anyClient is AutoWiredClientImp)
  }
  
  func testThatItUsesAutoWireFactoryWithMostNumberOfArguments() {
    //given
    
    //1 arg
    container.register { AutoWiredClientImp(service1: $0, service2: try self.container.resolve()) as AutoWiredClient }
    //1 arg
    container.register { AutoWiredClientImp(service1: try self.container.resolve(), service2: $0) as AutoWiredClient }
    
    //2 args
    var factoryWithMostNumberOfArgumentsCalled = false
    container.register { AutoWiredClientImp(service1: $0, service2: $1) as AutoWiredClient }
      .resolvingProperties { _,_  in
        factoryWithMostNumberOfArgumentsCalled = true
    }
    
    container.register { ServiceImp1() as Service }
    container.register { ServiceImp2() }
    
    //when
    let _ = try! container.resolve() as AutoWiredClient
    
    //then
    XCTAssertTrue(factoryWithMostNumberOfArgumentsCalled)
  }
  
  func testThatItThrowsAmbiguityErrorWhenUsingAutoWire() {
    //given
    
    //1 arg
    container.register { AutoWiredClientImp(service1: $0, service2: try self.container.resolve()) as AutoWiredClient }
    //1 arg
    container.register { AutoWiredClientImp(service1: try self.container.resolve(), service2: $0) as AutoWiredClient }
    
    container.register { ServiceImp1() as Service }
    container.register { ServiceImp2() }
    
    //when
    AssertThrows(expression: try container.resolve() as AutoWiredClient) { error -> Bool in
      switch error {
      case let DipError.autoWiringFailed(_, error):
        if case DipError.ambiguousDefinitions = error { return true }
        else { return false }
      default: return false
      }
    }
  }
  
  func testThatItPrefersTaggedFactoryWithDifferentNumberOfArgumentsWhenUsingAutoWire() {
    //given
    
    //1 arg
    container.register { AutoWiredClientImp(service1: $0, service2: try self.container.resolve()) as AutoWiredClient }
    //1 arg
    container.register { AutoWiredClientImp(service1: try self.container.resolve(), service2: $0) as AutoWiredClient }
    
    //2 args
    container.register { AutoWiredClientImp(service1: $0, service2: $1) as AutoWiredClient }
    
    //1 arg tagged
    var taggedFactoryWithMostNumberOfArgumentsCalled = false
    container.register(tag: "tag") { AutoWiredClientImp(service1: $0, service2: try self.container.resolve()) as AutoWiredClient }
    
    //2 arg tagged
    container.register(tag: "tag") { AutoWiredClientImp(service1: $0, service2: $1) as AutoWiredClient }.resolvingProperties { _,_  in
      taggedFactoryWithMostNumberOfArgumentsCalled = true
    }

    container.register() { ServiceImp1() as Service }
    container.register { ServiceImp2() }
    
    //when
    let _ = try! container.resolve(tag: "tag") as AutoWiredClient
    
    //then
    XCTAssertTrue(taggedFactoryWithMostNumberOfArgumentsCalled)
  }
  
  func testThatItPrefersTaggedFactoryWithDifferentTypesOfArgumentsWhenUsingAutoWire() {
    //given
    
    //1 arg
    container.register { AutoWiredClientImp(service1: $0, service2: try self.container.resolve()) as AutoWiredClient }
    
    //2 args
    container.register { AutoWiredClientImp(service1: $0, service2: $1) as AutoWiredClient }
    
    //1 arg tagged
    var taggedFactoryCalled = false
    container.register(tag: "tag") { AutoWiredClientImp(service1: try self.container.resolve(), service2: $0) as AutoWiredClient }.resolvingProperties { _,_  in
      taggedFactoryCalled = true
    }
    
    container.register() { ServiceImp1() as Service }
    container.register { ServiceImp2() }
    
    //when
    let _ = try! container.resolve(tag: "tag") as AutoWiredClient
    
    //then
    XCTAssertTrue(taggedFactoryCalled)
  }
  
  func testThatItFallbackToNotTaggedFactoryWhenUsingAutoWire() {
    //given
    
    //1 arg
    var notTaggedFactoryWithMostNumberOfArgumentsCalled = false
    container.register { AutoWiredClientImp(service1: $0, service2: try self.container.resolve()) as AutoWiredClient }.resolvingProperties { _,_  in
      notTaggedFactoryWithMostNumberOfArgumentsCalled = true
    }
    
    //1 arg tagged
    container.register(tag: "tag") { AutoWiredClientImp(service1: $0, service2: try self.container.resolve()) as AutoWiredClient }
    
    container.register { ServiceImp1() as Service }
    container.register { ServiceImp2() }
    
    //when
    let _ = try! container.resolve(tag: "other tag") as AutoWiredClient
    
    //then
    XCTAssertTrue(notTaggedFactoryWithMostNumberOfArgumentsCalled)
  }
  
  func testThatItDoesNotTryToUseAutoWiringWhenCallingResolveWithArguments() {
    //given
    container.register { AutoWiredClientImp(service1: $0, service2: $1) as AutoWiredClient }
    container.register { ServiceImp1() as Service }
    container.register { ServiceImp2() }
    
    //when
    let service = try! container.resolve() as Service
    AssertThrows(expression: try container.resolve(arguments: service) as AutoWiredClient,
      "Container should not use auto-wiring when resolving with runtime arguments")
  }
  
  func testThatItDoesNotUseAutoWiringWhenFailedToResolveLowLevelDependency() {
    //given
    container.register { AutoWiredClientImp() as AutoWiredClient }
      .resolvingProperties { container, resolved in
        resolved.service1 = try container.resolve() as Service
        resolved.service2 = try container.resolve() as ServiceImp2
        
        //simulate that something goes wrong on the way
        throw DipError.definitionNotFound(key: DefinitionKey(type: ServiceImp1.self, typeOfArguments: Any.self))
    }
    
    container.register { AutoWiredClientImp(service1: $0, service2: $1) as AutoWiredClient }
      .resolvingProperties { container, resolved in
        //auto-wiring should be performed only when definition for type to resolve is not found
        //but not for any other type along the way in the graph
        XCTFail("Auto-wiring should not be performed if instance was actually resolved.")
    }
    
    container.register { ServiceImp1() as Service }
    container.register { ServiceImp2() }
    
    //then
    AssertThrows(expression: try container.resolve() as AutoWiredClient,
      "Container should not use auto-wiring when definition for resolved type is registered.")
  }
  
  func testThatItReusesInstancesResolvedWithAutoWiringWhenUsingAutoWiringAgain() {
    
    //given
    container.register { ServiceImp1() as Service }
    container.register { ServiceImp2() }
    
    var anotherInstance: AutoWiredClient?
    
    container.register { AutoWiredClientImp(service1: $0, service2: $1) as AutoWiredClient }
      .resolvingProperties { container, _ in
        if anotherInstance == nil {
          anotherInstance = try! container.resolve() as AutoWiredClient
        }
    }
    
    //when
    let resolved = try! container.resolve() as AutoWiredClient
    
    //then
    //when doing another auto-wiring during resolve we should reuse instance
    XCTAssertTrue((resolved as! AutoWiredClientImp) === (anotherInstance as! AutoWiredClientImp))
  }
  
  func testThatItReusesInstancesResolvedWithoutAutoWiringWhenUsingAutoWiringAgain() {
    
    //given
    container.register { ServiceImp1() as Service }
    container.register { ServiceImp2() }
    
    var anotherInstance: AutoWiredClient?
    
    container.register { AutoWiredClientImp(service1: $0, service2: $1) as AutoWiredClient }
      .resolvingProperties { container, _ in
        if anotherInstance == nil {
          anotherInstance = try! container.resolve() as AutoWiredClient
        }
    }
    
    //when
    let service1 = try! container.resolve() as Service?
    let service2 = try! container.resolve() as ServiceImp2
    let resolved = try! container.resolve(arguments: service1, service2) as AutoWiredClient
    
    //then
    //when doing another auto-wiring during resolve we should reuse instance
    XCTAssertTrue((resolved as! AutoWiredClientImp) === (anotherInstance as! AutoWiredClientImp))
  }

  func testThatItReusesInstancesResolvedWithAutoWiringWhenUsingAutoWiringAgainWithTheSameTag() {
    
    //given
    container.register { ServiceImp1() as Service }
    container.register { ServiceImp2() }
    
    var anotherInstance: AutoWiredClient?
    
    container.register(tag: "tag") { AutoWiredClientImp(service1: $0, service2: $1) as AutoWiredClient }
      .resolvingProperties { container, _ in
        if anotherInstance == nil {
          anotherInstance = try! container.resolve(tag: "tag") as AutoWiredClient
        }
    }
    
    //when
    let resolved = try! container.resolve(tag: "tag") as AutoWiredClient
    
    //then
    //when doing another auto-wiring during resolve we should reuse instance
    XCTAssertTrue((resolved as! AutoWiredClientImp) === (anotherInstance as! AutoWiredClientImp))
  }
  
  func testThatItDoesNotReuseInstancesResolvedWithAutoWiringWhenUsingAutoWiringAgainWithAnotherTag() {
    
    //given
    container.register { ServiceImp1() as Service }
    container.register { ServiceImp2() }
    
    var anotherInstance: AutoWiredClient?
    
    container.register { AutoWiredClientImp(service1: $0, service2: $1) as AutoWiredClient }
      .resolvingProperties { container, _ in
        if anotherInstance == nil {
          anotherInstance = try! container.resolve() as AutoWiredClient
        }
    }
    
    //when
    let resolved = try! container.resolve(tag: "tag") as AutoWiredClient
    
    //then
    //when doing another auto-wiring during resolve we should reuse instance
    XCTAssertTrue((resolved as! AutoWiredClientImp) !== (anotherInstance as! AutoWiredClientImp))
  }
  
  func testThatItUsesTagToResolveDependenciesWithAutoWiringWith1Argument() {
    //given
    container.register { ServiceImp1() as Service }
    container.register(tag: "tag") { ServiceImp2() as Service }
    
    container.register { (dep1: Service) -> ServiceImp3 in
      XCTAssertTrue(dep1 is ServiceImp2)
      return ServiceImp3()
    }
    
    //when
    let _ = try! container.resolve(tag: "tag") as ServiceImp3
  }

  func testThatItUsesTagToResolveDependenciesWithAutoWiringWith2Arguments() {
    //given
    container.register { ServiceImp1() as Service }
    container.register(tag: "tag") { ServiceImp2() as Service }
    
    container.register { (dep1: Service, dep2: Service) -> ServiceImp3 in
      XCTAssertTrue(dep1 is ServiceImp2)
      XCTAssertTrue(dep2 is ServiceImp2)
      return ServiceImp3()
    }
    
    //when
    let _ = try! container.resolve(tag: "tag") as ServiceImp3
  }

  func testThatItUsesTagToResolveDependenciesWithAutoWiringWith3Arguments() {
    //given
    container.register { ServiceImp1() as Service }
    container.register(tag: "tag") { ServiceImp2() as Service }
    
    container.register { (dep1: Service, dep2: Service, dep3: Service) -> ServiceImp3 in
      XCTAssertTrue(dep1 is ServiceImp2)
      XCTAssertTrue(dep2 is ServiceImp2)
      XCTAssertTrue(dep3 is ServiceImp2)
      return ServiceImp3()
    }
    
    //when
    let _ = try! container.resolve(tag: "tag") as ServiceImp3
  }

  func testThatItUsesTagToResolveDependenciesWithAutoWiringWith4Arguments() {
    //given
    container.register { ServiceImp1() as Service }
    container.register(tag: "tag") { ServiceImp2() as Service }
    
    container.register { (dep1: Service, dep2: Service, dep3: Service, dep4: Service) -> ServiceImp3 in
      XCTAssertTrue(dep1 is ServiceImp2)
      XCTAssertTrue(dep2 is ServiceImp2)
      XCTAssertTrue(dep3 is ServiceImp2)
      XCTAssertTrue(dep4 is ServiceImp2)
      return ServiceImp3()
    }
    
    //when
    let _ = try! container.resolve(tag: "tag") as ServiceImp3
  }

  func testThatItUsesTagToResolveDependenciesWithAutoWiringWith5Arguments() {
    //given
    container.register { ServiceImp1() as Service }
    container.register(tag: "tag") { ServiceImp2() as Service }
    
    container.register { (dep1: Service, dep2: Service, dep3: Service, dep4: Service, dep5: Service) -> ServiceImp3 in
      XCTAssertTrue(dep1 is ServiceImp2)
      XCTAssertTrue(dep2 is ServiceImp2)
      XCTAssertTrue(dep3 is ServiceImp2)
      XCTAssertTrue(dep4 is ServiceImp2)
      XCTAssertTrue(dep5 is ServiceImp2)
      return ServiceImp3()
    }
    
    //when
    let _ = try! container.resolve(tag: "tag") as ServiceImp3
  }

  func testThatItUsesTagToResolveDependenciesWithAutoWiringWith6Arguments() {
    //given
    container.register { ServiceImp1() as Service }
    container.register(tag: "tag") { ServiceImp2() as Service }
    
    container.register { (dep1: Service, dep2: Service, dep3: Service, dep4: Service, dep5: Service, dep6: Service) -> ServiceImp3 in
      XCTAssertTrue(dep1 is ServiceImp2)
      XCTAssertTrue(dep2 is ServiceImp2)
      XCTAssertTrue(dep3 is ServiceImp2)
      XCTAssertTrue(dep4 is ServiceImp2)
      XCTAssertTrue(dep5 is ServiceImp2)
      XCTAssertTrue(dep6 is ServiceImp2)
      return ServiceImp3()
    }
    
    //when
    let _ = try! container.resolve(tag: "tag") as ServiceImp3
  }

  func testThatItCanAutoWireOptional() {
    //given
    container.register { ServiceImp1() as Service }
    container.register { ServiceImp2() }
    container.register { AutoWiredClientImp(service1: $0, service2: $1) as AutoWiredClient }
    
    var resolved: AutoWiredClient?
    //when
    AssertNoThrow(expression: resolved = try container.resolve() as AutoWiredClient?)
    XCTAssertNotNil(resolved)
    
    //when
    AssertNoThrow(expression: resolved = try container.resolve(tag: "tag") as AutoWiredClient?)
    XCTAssertNotNil(resolved)
  }
  
}



class ResolveTestsTests: XCTestCase {
  var container : DependencyContainer!
  
  override func setUp() {
    let container = DependencyContainer()
    
    container.register(.singleton) { Service01() }
    container.register(.singleton) { Service02() }
    container.register(.singleton) { Service03() }
    container.register(.singleton) { Service04() }
    container.register(.singleton) { Service05() }
    container.register(.singleton) { Service06() }
    container.register(.singleton) { Service07() }
    container.register(.singleton) { Service08() }
    container.register(.singleton) { Service09() }
    container.register(.singleton) { Service10() }
    container.register(.singleton) { Service11() }
    container.register(.singleton) { Service12() }
    container.register(.singleton) { Service13() }
    container.register(.singleton) { Service14() }
    container.register(.singleton) { Service15() }
    container.register(.singleton) { Service16() }
    container.register(.singleton) { Service17() }
    container.register(.singleton) { Service18() }
    container.register(.singleton) { Service19() }
    container.register(.singleton) { Service20() }
    container.register(.singleton) { Service21() }
    container.register(.singleton) { Service22() }
    container.register(.singleton) { Service23() }
    container.register(.singleton) { Service24() }
    container.register(.singleton) { Service25() }
    container.register(.singleton) { Service26() }
    container.register(.singleton) { Service27() }
    container.register(.singleton) { Service28() }
    container.register(.singleton) { Service29() }
    container.register(.singleton) { Service30() }
    container.register(.singleton) { Service31() }
    container.register(.singleton) { Service32() }
    container.register(.singleton) { Service33() }
    container.register(.singleton) { Service34() }
    container.register(.singleton) { Service35() }
    container.register(.singleton) { Service36() }
    container.register(.singleton) { Service37() }
    container.register(.singleton) { Service38() }
    container.register(.singleton) { Service39() }
    container.register(.singleton) { Service40() }
    container.register(.singleton) { Service41() }
    container.register(.singleton) { Service42() }
    container.register(.singleton) { Service43() }
    container.register(.singleton) { Service44() }
    container.register(.singleton) { Service45() }
    container.register(.singleton) { Service46() }
    container.register(.singleton) { Service47() }
    container.register(.singleton) { Service48() }
    container.register(.singleton) { Service49() }
    container.register(.singleton) { Service50() }
    container.register(.singleton) { Service51() }
    container.register(.singleton) { Service52() }
    container.register(.singleton) { Service53() }
    container.register(.singleton) { Service54() }
    container.register(.singleton) { Service55() }
    container.register(.singleton) { Service56() }
    container.register(.singleton) { Service57() }
    container.register(.singleton) { Service58() }
    container.register(.singleton) { Service59() }
    container.register(.singleton) { Service60() }
    container.register(.singleton) { Service61() }
    container.register(.singleton) { Service62() }
    container.register(.singleton) { Service63() }
    container.register(.singleton) { Service64() }
    container.register(.singleton) { Service65() }
    container.register(.singleton) { Service66() }
    container.register(.singleton) { Service67() }
    container.register(.singleton) { Service68() }
    container.register(.singleton) { Service69() }
    container.register(.singleton) { Service70() }
    container.register(.singleton) { Service71() }
    container.register(.singleton) { Service72() }
    container.register(.singleton) { Service73() }
    container.register(.singleton) { Service74() }
    container.register(.singleton) { Service75() }
    container.register(.singleton) { Service76() }
    container.register(.singleton) { Service77() }
    container.register(.singleton) { Service78() }
    container.register(.singleton) { Service79() }
    container.register(.singleton) { Service80() }
    container.register(.singleton) { Service81() }
    container.register(.singleton) { Service82() }
    container.register(.singleton) { Service83() }
    container.register(.singleton) { Service84() }
    container.register(.singleton) { Service85() }
    container.register(.singleton) { Service86() }
    container.register(.singleton) { Service87() }
    container.register(.singleton) { Service88() }
    container.register(.singleton) { Service89() }
    container.register(.singleton) { Service90() }
    container.register(.singleton) { Service91() }
    container.register(.singleton) { Service92() }
    container.register(.singleton) { Service93() }
    container.register(.singleton) { Service94() }
    container.register(.singleton) { Service95() }
    container.register(.singleton) { Service96() }
    container.register(.singleton) { Service97() }
    container.register(.singleton) { Service98() }
    container.register(.singleton) { Service99() }
    self.container = container
    
    _ = try! container.resolve() as Service01
    _ = try! container.resolve() as Service02
    _ = try! container.resolve() as Service03
    _ = try! container.resolve() as Service04
    _ = try! container.resolve() as Service05
    _ = try! container.resolve() as Service06
    _ = try! container.resolve() as Service07
    _ = try! container.resolve() as Service08
    _ = try! container.resolve() as Service09
    _ = try! container.resolve() as Service10
    _ = try! container.resolve() as Service11
    _ = try! container.resolve() as Service12
    _ = try! container.resolve() as Service13
    _ = try! container.resolve() as Service14
    _ = try! container.resolve() as Service15
    _ = try! container.resolve() as Service16
    _ = try! container.resolve() as Service17
    _ = try! container.resolve() as Service18
    _ = try! container.resolve() as Service19
    _ = try! container.resolve() as Service20
    _ = try! container.resolve() as Service21
    _ = try! container.resolve() as Service22
    _ = try! container.resolve() as Service23
    _ = try! container.resolve() as Service24
    _ = try! container.resolve() as Service25
    _ = try! container.resolve() as Service26
    _ = try! container.resolve() as Service27
    _ = try! container.resolve() as Service28
    _ = try! container.resolve() as Service29
    _ = try! container.resolve() as Service30
    _ = try! container.resolve() as Service31
    _ = try! container.resolve() as Service32
    _ = try! container.resolve() as Service33
    _ = try! container.resolve() as Service34
    _ = try! container.resolve() as Service35
    _ = try! container.resolve() as Service36
    _ = try! container.resolve() as Service37
    _ = try! container.resolve() as Service38
    _ = try! container.resolve() as Service39
    _ = try! container.resolve() as Service40
    _ = try! container.resolve() as Service41
    _ = try! container.resolve() as Service42
    _ = try! container.resolve() as Service43
    _ = try! container.resolve() as Service44
    _ = try! container.resolve() as Service45
    _ = try! container.resolve() as Service46
    _ = try! container.resolve() as Service47
    _ = try! container.resolve() as Service48
    _ = try! container.resolve() as Service49
    _ = try! container.resolve() as Service50
    _ = try! container.resolve() as Service51
    _ = try! container.resolve() as Service52
    _ = try! container.resolve() as Service53
    _ = try! container.resolve() as Service54
    _ = try! container.resolve() as Service55
    _ = try! container.resolve() as Service56
    _ = try! container.resolve() as Service57
    _ = try! container.resolve() as Service58
    _ = try! container.resolve() as Service59
    _ = try! container.resolve() as Service60
    _ = try! container.resolve() as Service61
    _ = try! container.resolve() as Service62
    _ = try! container.resolve() as Service63
    _ = try! container.resolve() as Service64
    _ = try! container.resolve() as Service65
    _ = try! container.resolve() as Service66
    _ = try! container.resolve() as Service67
    _ = try! container.resolve() as Service68
    _ = try! container.resolve() as Service69
    _ = try! container.resolve() as Service70
    _ = try! container.resolve() as Service71
    _ = try! container.resolve() as Service72
    _ = try! container.resolve() as Service73
    _ = try! container.resolve() as Service74
    _ = try! container.resolve() as Service75
    _ = try! container.resolve() as Service76
    _ = try! container.resolve() as Service77
    _ = try! container.resolve() as Service78
    _ = try! container.resolve() as Service79
    _ = try! container.resolve() as Service80
    _ = try! container.resolve() as Service81
    _ = try! container.resolve() as Service82
    _ = try! container.resolve() as Service83
    _ = try! container.resolve() as Service84
    _ = try! container.resolve() as Service85
    _ = try! container.resolve() as Service86
    _ = try! container.resolve() as Service87
    _ = try! container.resolve() as Service88
    _ = try! container.resolve() as Service89
    _ = try! container.resolve() as Service90
    _ = try! container.resolve() as Service91
    _ = try! container.resolve() as Service92
    _ = try! container.resolve() as Service93
    _ = try! container.resolve() as Service94
    _ = try! container.resolve() as Service95
    _ = try! container.resolve() as Service96
    _ = try! container.resolve() as Service97
    _ = try! container.resolve() as Service98


  }
  
  func testStress() {
    let option = XCTMeasureOptions.init()
      option.iterationCount = 1
          
      self.measure(options: option) {
          _ = try! container.resolve() as Service99
      }
  }
}


struct Service01 {}
struct Service02 {}
struct Service03 {}
struct Service04 {}
struct Service05 {}
struct Service06 {}
struct Service07 {}
struct Service08 {}
struct Service09 {}
struct Service10 {}
struct Service11 {}
struct Service12 {}
struct Service13 {}
struct Service14 {}
struct Service15 {}
struct Service16 {}
struct Service17 {}
struct Service18 {}
struct Service19 {}
struct Service20 {}
struct Service21 {}
struct Service22 {}
struct Service23 {}
struct Service24 {}
struct Service25 {}
struct Service26 {}
struct Service27 {}
struct Service28 {}
struct Service29 {}
struct Service30 {}
struct Service31 {}
struct Service32 {}
struct Service33 {}
struct Service34 {}
struct Service35 {}
struct Service36 {}
struct Service37 {}
struct Service38 {}
struct Service39 {}
struct Service40 {}
struct Service41 {}
struct Service42 {}
struct Service43 {}
struct Service44 {}
struct Service45 {}
struct Service46 {}
struct Service47 {}
struct Service48 {}
struct Service49 {}
struct Service50 {}
struct Service51 {}
struct Service52 {}
struct Service53 {}
struct Service54 {}
struct Service55 {}
struct Service56 {}
struct Service57 {}
struct Service58 {}
struct Service59 {}
struct Service60 {}
struct Service61 {}
struct Service62 {}
struct Service63 {}
struct Service64 {}
struct Service65 {}
struct Service66 {}
struct Service67 {}
struct Service68 {}
struct Service69 {}
struct Service70 {}
struct Service71 {}
struct Service72 {}
struct Service73 {}
struct Service74 {}
struct Service75 {}
struct Service76 {}
struct Service77 {}
struct Service78 {}
struct Service79 {}
struct Service80 {}
struct Service81 {}
struct Service82 {}
struct Service83 {}
struct Service84 {}
struct Service85 {}
struct Service86 {}
struct Service87 {}
struct Service88 {}
struct Service89 {}
struct Service90 {}
struct Service91 {}
struct Service92 {}
struct Service93 {}
struct Service94 {}
struct Service95 {}
struct Service96 {}
struct Service97 {}
struct Service98 {}
struct Service99 {}

