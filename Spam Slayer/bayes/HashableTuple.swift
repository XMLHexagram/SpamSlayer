//
//  HashableTuple.swift
//  Bayes
//
//  Created by Fabian Canas on 5/9/15.
//  Copyright (c) 2015 Fabian Canas. All rights reserved.
//

/** 
 A (Hashable, Hashable) isn't Hashable. But representing conditional
 probabilities in a Set or Dictionary is easier if they are.
*/
internal struct HashableTuple<A : Hashable & Codable, B : Hashable & Codable> : Hashable, Codable {
    let a :A
    let b :B
    
    init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }
}

internal func == <A, B> (lhs: HashableTuple<A,B>, rhs: HashableTuple<A,B>) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b
}
