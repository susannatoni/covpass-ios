//
//  NoMaskRulesResultViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import UIKit

protocol NoMaskRulesResultViewModelProtocol: CancellableViewModelProtocol {
    var delegate: ViewModelDelegate? { get set }
    var image: UIImage { get }
    var title: String { get }
    var subtitle: String { get }
    var summary: String { get }
    var description: String { get }
    var buttonTitle: String { get }
    var countdownTimerModel: CountdownTimerModel { get }

    func rescan()
}
