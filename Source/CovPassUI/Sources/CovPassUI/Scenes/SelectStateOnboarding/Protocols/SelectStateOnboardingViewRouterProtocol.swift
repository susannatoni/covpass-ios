//
//  SelectStateOnboardingViewRouterProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit

public protocol SelectStateOnboardingViewRouterProtocol: RouterProtocol {
    func showFederalStateSelection() -> Promise<Void>
}
