//
//  BoxBind.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import Foundation

class BoxBind<T> {
    typealias Listener = (T) -> ()
    
    // MARK:- variables for the binder
    var value: T {
        didSet {
            listener?(value)
        }
    }
    var listener: Listener?
    
    // MARK:- initializers for the binder
    init(_ value: T) {
        self.value = value
    }
    
    // MARK:- functions for the binder
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
