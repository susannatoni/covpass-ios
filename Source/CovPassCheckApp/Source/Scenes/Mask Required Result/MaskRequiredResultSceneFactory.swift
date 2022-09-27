//
//  MaskRequiredResultSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct MaskRequiredResultSceneFactory: ResolvableSceneFactory {
    private let router: MaskRequiredResultRouterProtocol

    init(router: MaskRequiredResultRouterProtocol) {
        self.router = router
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let persistence = UserDefaultsPersistence()
        let federalStateCode = persistence.stateSelection
        #warning("TODO: Set reason type, after scan story is done.")
        let reasonType: MaskRequiredReasonType = .technical
        let countdownTimerModel = CountdownTimerModel(
            dismissAfterSeconds: 120,
            countdownDuration: 60
        )
        let viewModel = MaskRequiredResultViewModel(
            countdownTimerModel: countdownTimerModel,
            federalStateCode: federalStateCode,
            resolver: resolvable,
            router: router,
            reasonType: reasonType
        )
        let viewController = MaskRequiredResultViewController(viewModel: viewModel)

        return viewController
    }
}
