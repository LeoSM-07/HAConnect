//
// HAManager.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import HAKit
import SwiftUI

class HAKitViewModel: ObservableObject {

    init() {
        getUser()
        getEntities()
        getRoomEntities()
    }

    let connection = HAKit.connection(configuration: .init(
        connectionInfo: {
            // Connection is required to be returned synchronously.
            // In a real implementation, handle both URL/connection info without crashing.
            try! .init(url: URL(string: AppSecrets().url)!)
        },
        fetchAuthToken: { completion in
            // Access tokens are retrieved asynchronously, but be aware that Home Assistant
            // has a timeout of 10 seconds for sending your access token.
            completion(.success(AppSecrets().token))
        }
    ))

    func getEntities() {
        connection.send(.getStates()) { result in
            switch result {
            case let .success(states):
                self.entities = states
            case let .failure(error):
                print(error)
            }
        }
    }

    func callService(id: String, d: String, s: String) {
        connection.send(.callService(
            domain: HAServicesDomain(rawValue: d),
            service: HAServicesService(rawValue: s),
            data: ["entity_id": id]
        )) { result in
            switch result {
            case let .success(data):
                print(data)
            case let .failure(error):
                print(error)
            }
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func getUser() {
        print("Attempting to get user...")
        connection.send(.currentUser()) { result in
            switch result {
            case let .success(returnedUser):
                print(returnedUser.name ?? "No User Name")
                self.user = returnedUser
            case let .failure(error):
                print(error)
            }
        }
    }

    @Published var roomIdList: [String] = ["leo_s_bedroom", "Our Bedroom"]
    @Published var roomEntityList: [[String]] = []

    func getRoomEntities() {

        var templateText = "{{ area_entities('"
        templateText.append(roomIdList.joined(separator: "') }},{{ area_entities('"))
        templateText.append("') }}")

        print("Attempting to print area...")
        connection.subscribe(
            to: .renderTemplate(templateText),
            initiated: { result in },
            handler: {cancelToken, response in
                // the overall response is parsed for type, but native template rendering means
                // the rendered type will be a Dictionary, Array, etc.
                if let object = response.result as? [[String]] {
                    self.roomEntityList = object
                }
                cancelToken.cancel()
            }
        )
    }

    @Published var user: HAResponseCurrentUser = HAResponseCurrentUser(
        id: "",
        name: "",
        isOwner: false,
        isAdmin: false,
        credentials: [HAResponseCurrentUser.Credential(type: "", id: "")],
        mfaModules: [HAResponseCurrentUser.MFAModule(id: "", name: "", isEnabled: false)]
    )

    @Published var entities: [HAEntity] = []

    var availableEntityDomains: [String] {
        return unique(source: entities.map({ HAEntity in
            HAEntity.domain
        }))
    }
}

func unique<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
    var buffer = [T]()
    var added = Set<T>()
    for elem in source {
        if !added.contains(elem) {
            buffer.append(elem)
            added.insert(elem)
        }
    }
    return buffer
}

