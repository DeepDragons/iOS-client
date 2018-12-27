//
//  NetworkError.swift
//  DragonETH
//
//  Created by Alexander Batalov on 9/14/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation

public enum NetworkError: String, Error {
    case noInternetConnection = "Can not establish internect connection"
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil"
}
