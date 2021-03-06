//
//  Product.swift
//  RxShop
//
//  Created by Greg Price on 01/02/2021.
//

import UIKit

struct Product: Decodable, Equatable {
    let id: String
    let title: String
    let description: String
    let price: Int
    let image: String
}

extension Product {
    var productImage: UIImage? {
        return UIImage(named: image)
    }
}
