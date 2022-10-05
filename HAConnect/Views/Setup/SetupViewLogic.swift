//
// SetupViewLogic.swift
// HAConnect
//
// Created by LeoSM_07 on 10/4/22.
//

import Foundation

extension SetupView {
    func checkSession(url: String, completionHandler: @escaping (String) -> Void) {
        print("Checking URL: \(url)")
        var request = URLRequest(url: URL(string: "\(url)api/")!,timeoutInterval: 10)
        request.addValue("Bearer \(tokenField)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    let error = String(describing: error)
                    print(error)
                    if error.contains("The request timed out.") {
                        completionHandler("REQUEST_TIMEOUT")
                    }
                    completionHandler("CONNECTION_ERROR")
                    return
                }
                let message = String(data: data, encoding: .utf8)!
                if message.contains("401") {
                    completionHandler("INVALID_TOKEN")
                }
                completionHandler("PASS")
                print("Passed")
            }
        }
        
        task.resume()
        
    }
}
