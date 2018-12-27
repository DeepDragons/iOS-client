//
//  NetworkRouter.swift
//  DragonETH
//
//  Created by Alexander Batalov on 9/14/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation

public typealias NetworkRouterCompletion = (_ data: Data?,_ response: URLResponse?,_ error: Error?)->()

protocol NetworkRouter: class {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, completetion: @escaping NetworkRouterCompletion)
    func cancel()
}

