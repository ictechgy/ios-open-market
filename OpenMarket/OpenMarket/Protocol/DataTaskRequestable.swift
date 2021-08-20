//
//  DataTaskRequestable.swift
//  OpenMarket
//
//  Created by 김준건 on 2021/08/17.
//

import Foundation

protocol DataTaskRequestable {
    mutating func runDataTask(using request: URLRequest, with completionHandler: @escaping (Result<Data, Error>) -> Void)
}
