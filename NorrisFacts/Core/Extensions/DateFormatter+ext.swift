//
//  DateFormatter+ext.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 07/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation

extension DateFormatter {

    static let yyyyMMdd_HHmmssSSSS: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        return formatter
    }()

}
