//
//  NSObjectExtension.swift
//  DragonETH
//
//  Created by Alexander Batalov on 5/30/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation
import ObjectiveC.NSObjCRuntime

/// NSObject associated object
public extension NSObject {
    
    /// keys
    private struct AssociatedKeys {
        static var descriptiveName = "associatedObject"
    }
    
    /// set associated object
    @objc public func setAssociated(object: Any) {
        objc_setAssociatedObject(self, &AssociatedKeys.descriptiveName, object, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// get associated object
    @objc public func associatedObject() -> Any? {
        return objc_getAssociatedObject(self, &AssociatedKeys.descriptiveName)
    }
}
