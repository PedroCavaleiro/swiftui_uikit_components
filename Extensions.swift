//
//  Extensions.swift
//
//  Created by Pedro Cavaleiro on 04/05/2020.
//  Copyright © 2020 Pedro Cavaleiro. All rights reserved.
//
//  This file contains some extensions that I find usefull
//  these extensions are not only for SwiftUI
//  This extension was not developed by me but I applied 
//  a fix that now allows to choose your own size
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        var chunkedArray = [[Element]]()
        var fixOffset = size - 1
        for index in 0...self.count {
            if index % size == 0 && index != 0 {
                chunkedArray.append(Array(self[(index - size)..<index]))
            } else if index == self.count {
                chunkedArray.append(Array(self[(index - fixOffset..<index)]))
            }
        }
        return chunkedArray
    }
}
