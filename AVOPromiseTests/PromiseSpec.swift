//
//  PromiseSpecs.swift
//  FruitilsKit
//
//  Created by Ben D. Jones on 8/28/14.
//  Copyright (c) 2014 Avocado Software Inc. All rights reserved.
//

import Quick
import Nimble

class PromiseSpec: QuickSpec {
    override func spec() {
        let exampleError = NSError(domain: "EPIC FAIL", code: 666, userInfo: nil)
        
        describe("a promise") {

            describe("when rejected") {
                it("should call the rejected callback with error when marked as rejected") {
                    let promise = Promise<String>()
                    
                    var called = false
                    var calledError: NSError?
                    
                    promise.whenRejected { (error: NSError) in
                        calledError = error
                        called = true
                    }
                    
                    promise.reject(exampleError)
                    
                    expect(calledError).toEventually(equal(exampleError))
                    expect(called).toEventually(beTruthy())
                }

                it("should not call the rejected callback when canceled") {
                    let promise = Promise<String>()
                    
                    var called = false
                    var calledError: NSError?
                    
                    promise.whenRejected { (error: NSError) in
                        calledError = error
                        called = true
                    }
                    
                    promise.cancel()
                    promise.reject(exampleError)
                    
                    expect(calledError).toEventually(beNil())
                    expect(called).toEventually(beFalsy())
                }

                it("should call many rejected callbacks if set, on error, but only once each") {
                    var errorArray = [NSError]()
                    
                    let promise = Promise<String>()
                    
                    promise.whenRejected { (error: NSError) in
                        errorArray.append(error)
                    }.whenRejected { (error: NSError) in
                        errorArray.append(error)
                    }.whenRejected { (error: NSError) in
                        errorArray.append(error)
                    }
                    
                    promise.reject(exampleError)
                    
                    expect(errorArray.count).toEventually(equal(3))
                    
                    it("and it calls rejected callback set after the reject call") {
                        
                        promise.whenRejected { (error: NSError) in
                            errorArray.append(error)
                        }
                        
                        expect(errorArray.count).toEventually(equal(4))
                    }
                }
            }
            
            describe("when resolved") {
                it("should call resolve callback with the value") {
                    let promise = Promise<String>()
                    
                    var called = false
                    var value: String?
                    
                    promise.whenResolved { (result: String) in
                        value = result
                        called = true
                    }
                    
                    promise.resolve("SUCCESS")
                    
                    expect(value).toEventually(equal("SUCCESS"))
                    expect(called).toEventually(beTruthy())
                }
                
                it("should not call resolve callback when canceled") {
                    let promise = Promise<String>()
                    
                    var called = false
                    var value: String?
                    
                    promise.whenResolved { (result: String) in
                        value = result
                        called = true
                    }
                    
                    promise.cancel()
                    promise.resolve("SUCCESS")
                    
                    expect(value).toEventually(beNil())
                    expect(called).toEventually(beFalsy())
                }
                
                it("should call many resolve callbacks if set, on success, but only once each") {
                    var resultArray = [String]()
                    
                    let promise = Promise<String>()
                    
                    promise.whenResolved { (result: String) in
                        resultArray.append(result)
                    }.whenResolved { (result: String) in
                            resultArray.append(result)
                    }.whenResolved { (result: String) in
                            resultArray.append(result)
                    }
                    
                    promise.resolve("SUCCESS")
                    
                    expect(resultArray.count).toEventually(equal(3))
                    
                    it("and it calls resolved callback set after the resolve call") {
                        
                        promise.whenResolved { (result: String) in
                            resultArray.append(result)
                        }
                        
                        expect(resultArray.count).toEventually(equal(4))
                    }
                }
            }
            
            describe("when fulfilled") {
                it("should call the fulfilled callback when resolved") {
                    let promise = Promise<String>()
                    
                    var called = false
                    
                    promise.whenFulfilled {
                        called = true
                    }
                    
                    promise.resolve("SUCCESS")
                    
                    expect(called).toEventually(beTruthy())
                }
                
                it("should call the fulfilled callback when rejected") {
                    let promise = Promise<String>()
                    
                    var called = false
                    
                    promise.whenFulfilled {
                        called = true
                    }
                    
                    promise.reject(exampleError)
                    
                    expect(called).toEventually(beTruthy())
                }
                
                describe("when canceled") {
                    it("should not call fulfilled callback when canceled and resolved") {
                        let promise = Promise<String>()
                        
                        var called = false
                        
                        promise.whenFulfilled {
                            called = true
                        }
                        
                        promise.cancel()
                        promise.resolve("SUCCESS")
                        
                        expect(called).toEventually(beFalsy())
                    }
                    
                    it("should not call fulfilled callback when canceled and rejected") {
                        let promise = Promise<String>()
                        
                        var called = false
                        
                        promise.whenFulfilled {
                            called = true
                        }
                        
                        promise.cancel()
                        promise.reject(exampleError)
                        
                        expect(called).toEventually(beFalsy())
                    }
                }
                
                describe("multiple callback") {
                    it("should call many fulfilled callbacks if set, on success, but only once each") {
                        var resultArray = [Bool]()
                        
                        let promise = Promise<String>()
                        
                        promise.whenFulfilled { resultArray.append(true) }
                               .whenFulfilled { resultArray.append(true) }
                               .whenFulfilled { resultArray.append(true) }
                        
                        promise.resolve("SUCCESS")
                        
                        expect(resultArray.count).toEventually(equal(3))
                        
                        it("and it calls fulfilled callback set after the resolve call") {
                            promise.whenFulfilled { resultArray.append(true) }
                            
                            expect(resultArray.count).toEventually(equal(4))
                        }
                    }
                    
                    it("should call many fulfilled callbacks if set, on error, but only once each") {
                        var resultArray = [Bool]()
                        
                        let promise = Promise<String>()
                        
                        promise.whenFulfilled { resultArray.append(true) }
                            .whenFulfilled { resultArray.append(true) }
                            .whenFulfilled { resultArray.append(true) }
                        
                        promise.reject(exampleError)
                        
                        expect(resultArray.count).toEventually(equal(3))
                        
                        it("and it calls fulfilled callback set after the resolve call") {
                            promise.whenFulfilled { resultArray.append(true) }
                            
                            expect(resultArray.count).toEventually(equal(4))
                        }
                    }
                }
            }
        }
    }
}
