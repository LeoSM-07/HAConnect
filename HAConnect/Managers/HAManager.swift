//
// HAManager.swift
// HAConnect
//
// Created by LeoSM_07 on 10/2/22.
//

import HAKit
import SwiftUI

extension Dictionary {

    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }

    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
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

struct RoomItem: Identifiable, Codable, Hashable {

    var id = UUID()
    var isActive: Bool = true
    var roomId: String
    var roomName: String    
    var imageURL: String?
    var entities: [String] = []

}

class HAKitViewModel: ObservableObject {
    
    let appSettings = AppSettings()
    
    @Published var entities: [HAEntity] = []
//    @Published var roomEntityList: [[String]] = [[]]
    @Published var user: HAResponseCurrentUser = HAResponseCurrentUser(
        id: "",
        name: "",
        isOwner: false,
        isAdmin: false,
        credentials: [HAResponseCurrentUser.Credential(type: "", id: "")],
        mfaModules: [HAResponseCurrentUser.MFAModule(id: "", name: "", isEnabled: false)]
    )
    @Published var userImagePath: String = ""
    @Published var roomList: [RoomItem] = []
    @AppStorage("roomList_storage") var roomListData: Data = Data()
    
    func decodeRoomList() {
        guard let newRoomList = try? JSONDecoder().decode([RoomItem].self, from: roomListData) else {
            print("failed to decode room list")
            return
        }
        print("decoded room list")
        self.roomList = newRoomList
    }
    
    func saveRoomList() {
        guard let newroomList = try? JSONEncoder().encode(roomList) else {
            print("failed to save room list")
            return
        }
        print("saved room list")
        self.roomListData = newroomList
    }

    init() {
        getUser()
        getEntities()
        subscribeToChanges()
        decodeRoomList()
        getRoomEntities()
    }

    let connection = HAKit.connection(configuration: .init(
        connectionInfo: {
            // Connection is required to be returned synchronously.
            // In a real implementation, handle both URL/connection info without crashing.
            try! .init(url: AppSettings().useableURL!)
        },
        fetchAuthToken: { completion in
            // Access tokens are retrieved asynchronously, but be aware that Home Assistant
            // has a timeout of 10 seconds for sending your access token.
            completion(.success(AppSettings().token))
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

    func callService(id: String, d: String, s: String, data: Dictionary<String, Any>? ) {

        let entityData: [String: Any] = ["entity_id": id]
        var finalData: [String: Any] {
            if data != nil {
                return entityData.merged(with: data!)
            } else {
                return entityData
            }
        }

        connection.send(.callService(
            domain: HAServicesDomain(rawValue: d),
            service: HAServicesService(rawValue: s),
            data: finalData
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

    func populateRoomList() {
        connection.send(.getAreas()) { result in
            switch result {
            case let .success(result):
                
                self.roomList = result.map({ room in
                    RoomItem(
                        isActive: true,
                        roomId: room.id,
                        roomName: room.name,
                        imageURL: room.picture
                    )
                })
                print("Room List: \(self.roomList)")
                self.getRoomEntities()
                
            case let .failure(error):
                print(error)
            }
        }
    }
    
    
    func getRoomEntities() {
        
        var templateText = "{{ area_entities('"
        templateText.append(roomList.map({ $0.roomId }).joined(separator: "') }},{{ area_entities('"))
        templateText.append("') }}")

        print("Getting Entites For All Rooms")
        connection.subscribe(
            to: .renderTemplate(templateText),
            initiated: { result in },
            handler: {cancelToken, response in
                
                if let object = response.result as? [[String]] {
//                    self.roomEntityList = object
                    print("Returned list \(object)")
                    for (index, array) in object.enumerated(){
                        self.roomList[index].entities = array
                    }
                }
                cancelToken.cancel()
            }
        )
    }
 

    func subscribeToChanges() {
        connection.subscribe(
            to: .stateChanged()) { cancel, result in
                if let row = self.entities.firstIndex(where: {$0.entityId == result.entityId}) {
                    if result.newState != nil {
                        self.entities[row] = result.newState!
                    }
                }
            }
    }

    func updateEntityBrightness(id: String, new: Int) {
        if let row = self.entities.firstIndex(where: {$0.entityId == id}) {
            self.entities[row].attributes.dictionary["brightness"] = new
        }
    }
    func updateEntityState(id: String, new: String) {
        if let row = self.entities.firstIndex(where: {$0.entityId == id}) {
            self.entities[row].state = new
        }
    }

    func getUserImagePath() {
        connection.subscribe(
            to: .renderTemplate("{{ states.person|selectattr('attributes.user_id', '==', 'fc3451be751448f898860d3950661d9e')|map(attribute='attributes.entity_picture')|first }}"),
          initiated: { _ in },
          handler: { cancelToken, response in
              if let object = response.result as? String {
                  self.userImagePath = object
              }
            cancelToken.cancel()
          }
        )
    }

    var availableEntityDomains: [String] {
        return unique(source: entities.map({ HAEntity in
            HAEntity.domain
        }))
    }
}
