//
//  GCDBlackBox.swift
//  On The Map
//
//  Created by Jamie Nguyen on 12/5/17.
//  Copyright © 2017 Jamie Nguyen. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

