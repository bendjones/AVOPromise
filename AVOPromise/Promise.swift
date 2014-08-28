//
//  Promise.swift
//  FruitilsKit
//
//  Created by Ben Jones on 7/4/14.
//  Copyright (c) 2014 Avocado Software Inc. All rights reserved.
//

import Foundation

final public class Promise<T> {
    public typealias Resolved = T -> ()
    public typealias Rejected = NSError -> ()
    public typealias Fulfilled = () -> ()
    
    private var value: T?
    private var error: NSError?

    private var fulfilledCallbacks: [Fulfilled]
    private var resolvedCallbacks: [Resolved]
    private var rejectedCallbacks: [Rejected]

    private var resolved: Bool = false
    private var rejected: Bool = false
    private var canceled: Bool = false

    public required init() {
        fulfilledCallbacks = [Fulfilled]()
        resolvedCallbacks = [Resolved]()
        rejectedCallbacks = [Rejected]()
    }

    private var isFulfilled: Bool {
        get {
            return resolved || rejected
        }
    }

    /// Add a closure to be called when the promise is marked fulfilled, that is, either resolved or rejected
    ///
    /// :param: callback the closure to run when finished
    /// :returns: the promise which the callback was set for
    public func whenFulfilled(callback: Fulfilled) -> Self {
        if isFulfilled {
            callback()
        } else {
            fulfilledCallbacks.append(callback)
        }

        return self
    }

    /// Add a closure to be called when the promise is marked resolved
    ///
    /// :param: callback the closure to run when resolved, the closure is passed in the value passed to resolve
    /// :returns: the promise which the callback was set for
    public func whenResolved(callback: Resolved) -> Self {
        if resolved {
            callback(value!)
        } else {
            resolvedCallbacks.append(callback)
        }

        return self
    }

    /// Add a closure to be called the promise is marked rejected
    ///
    /// :param: callback the closure to run when rejected, the closure is passed in the error passed to reject
    /// :returns: the promise which the callback was set for
    public func whenRejected(callback: Rejected) -> Self {
        if rejected {
            callback(error!)
        } else {
            rejectedCallbacks.append(callback)
        }

        return self
    }

    /// Mark the promise resolved, the success case
    ///
    /// :param: value the returned result the promise was issued for, like a network request response
    public func resolve(value: T) -> Void {
        self.value = value

        resolved = true

        if canceled {
            return
        }

        for callback: Resolved in resolvedCallbacks {
            callback(value)
        }

        fulfill()
    }

    /// Mark the promise rejected, the failure case
    ///
    /// :param: error the error from the requested promise
    public func reject(err: NSError) -> Void {
        error = err
        rejected = true

        if canceled {
            return
        }

        for callback: Rejected in rejectedCallbacks {
            callback(err)
        }

        fulfill()
    }

    /// The promise has been fulfilled call all the fulfilled callbacks
    private func fulfill() -> Void {
        for callback: Fulfilled in fulfilledCallbacks {
            callback()
        }
    }
    
    public func cancel() -> Void {
        canceled = true
    }
}
