//
//  UITextField+RxHelpers.swift
//  RxShop
//
//  Created by Greg Price on 26/01/2021.
//

import UIKit
import RxSwift

extension UITextField {
    func observableText() -> Observable<String> {
        return rx.text.orEmpty.asObservable()
    }
}