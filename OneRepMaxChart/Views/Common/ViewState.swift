//
//  ViewState.swift
//  OneRepMaxChart
//
//  Created by hope on 7/8/24.
//

import Foundation

enum ViewState {
    case idle
    case loading
    case finished
    case failed(Error)
    
    var error: String? {
        guard case .failed(let error) = self else {
            return nil
        }
        return error.localizedDescription
    }
}
