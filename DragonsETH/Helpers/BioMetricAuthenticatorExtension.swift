//
//  BioMetricAuthenticatorExtension.swift
//  DragonETH
//
//  Created by Alexander Batalov on 5/30/18.
//  Copyright © 2018 Alexander Batalov. All rights reserved.
//

import Foundation
import BiometricAuthentication
import LocalAuthentication

extension BioMetricAuthenticator {
    public var defaultAuthenticationMethod: String {
        get {
            let context = LAContext()
            let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch context.biometryType {
            case .none:
                return "Password"
            case .touchID:
                return "Touch ID"
            case .faceID:
                return "Face ID"
            }

        }
    }
}

