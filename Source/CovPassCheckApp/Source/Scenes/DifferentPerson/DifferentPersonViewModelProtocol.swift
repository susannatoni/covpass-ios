//
//  DifferentPersonViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import UIKit

protocol DifferentPersonViewModelProtocol {
    var title: String { get }
    var subtitle: String { get }
    var firstResultCardImage: UIImage { get }
    var SecondResultCardImage: UIImage { get }
    var firstResultTitle: String { get }
    var secondResultTitle: String { get }
    var footerHeadline: String { get }
    var footerText: String { get }
    var footerLinkText: String { get }
    var startOverButton: String { get }
    var firstResultName: String { get }
    var firstResultNameTranslittered: String { get }
    var firstResultDateOfBirth: String { get }
    var secondResultName: String { get }
    var secondResultNameTranslittered: String { get }
    var secondResultDateOfBirth: String { get }
    var firstResultCert: CBORWebToken { get set }
    var secondResultCert: CBORWebToken { get set }
    var delegate: ViewModelDelegate? { get set }
    var countdownTimerModel: CountdownTimerModel { get }
    func startover()
    func ignoreButton()
}
