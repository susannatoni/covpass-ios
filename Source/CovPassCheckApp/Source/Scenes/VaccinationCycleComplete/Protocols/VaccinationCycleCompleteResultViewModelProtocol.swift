//
//  VaccinationCycleCompleteResultViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import UIKit

protocol VaccinationCycleCompleteResultViewModelProtocol: CancellableViewModelProtocol & CountdownViewModel {
    var delegate: ViewModelDelegate? { get set }
    var image: UIImage { get }
    var title: String { get }
    var subtitle: String { get }
    var description: String { get }
    var holderName: String { get }
    var holderNameTransliterated: String { get }
    var holderBirthday: String { get }
    var travelRules: String { get }
    var travelRulesIsHidden: Bool { get }
    var revocationInfoHidden: Bool { get }
    var revocationHeadline: String { get }
    var revocationInfoText: String { get }
    var revocationLinkTitle: String { get }
    var buttonTitle: String { get }
    var closeButtonAccessibilityText: String { get }

    func rescan()
    func revoke(_: Any)
}
