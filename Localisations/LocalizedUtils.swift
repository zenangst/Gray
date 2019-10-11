//
//  LocalizedUtils.swift
//  Gray
//
//  Created by Licardo on 2019/10/11.
//  Copyright © 2019 zenangst. All rights reserved.
//

import Foundation
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}
