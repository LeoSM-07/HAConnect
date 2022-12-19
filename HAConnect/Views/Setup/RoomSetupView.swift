//
// RoomSetupView.swift
// HAConnect
//
// Created by LeoSM_07 on 12/18/22.
//

import HAKit
import SwiftUI

struct RoomSetupView: View {
    @Environment(\.dismiss) var dismiss
    @State var roomNameText = ""
    @State var showAddEntities = false
    @State var entitySearchText = ""

    @State var mainItemsSelection: [HAEntity] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Room Details"){
                    HStack {
                        Image(systemName: "house.fill")
                            .foregroundColor(.accentColor)
                        TextField("Room Name", text: $roomNameText)
                    }
                }

                Section("Main Items") {
                    ForEach(mainItemsSelection, id: \.self) { selection in
                        Text(selection.attributes.friendlyName ?? selection.entityId)
                    }
                    Button("Select Entities"){
                        showAddEntities.toggle()
                    }
                }

                Section("Quick Actions (Optional)") {

                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add"){}
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel"){
                        dismiss()
                    }
                }
            }
            .navigationTitle("New Room")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showAddEntities) {
            EntitySelectorView(mainItemsSelection: $mainItemsSelection, searchText: $entitySearchText)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium, .large])
        }
    }
}

struct EntitySelectorView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var homeAssistant: HAKitViewModel
    @Binding var mainItemsSelection: [HAEntity]
    @Binding var searchText: String

    var selectedListSearched: [HAEntity] {
        if searchText != "" {
            return homeAssistant.entities.filter{ $0.attributes.friendlyName?.contains(searchText) ?? $0.entityId.contains(searchText)}
        } else {
            return homeAssistant.entities
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Lights") {
                    ForEach(selectedListSearched.filter({$0.entityId.hasPrefix("light.")}), id: \.self) { entity in
                        EntitySelectorListRowView(selectedList: $mainItemsSelection, entity: entity)
                    }
                }

                Section("Sensors") {
                    ForEach(selectedListSearched.filter({$0.entityId.hasPrefix("sensor.")}), id: \.self) { entity in
                        Text(entity.attributes.friendlyName ?? entity.entityId)
                    }
                }
            }
            .listStyle(.sidebar)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Add Entity")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

fileprivate struct EntitySelectorListRowView: View {
    @State var selected: Bool = false
    @Binding var selectedList: [HAEntity]
    let entity: HAEntity

    var body: some View {
        Button { selected.toggle() } label: {
            HStack {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.accentColor)
                Text(entity.attributes.friendlyName ?? entity.entityId)
            }
        }
        .onChange(of: selected) { newValue in
            switch newValue {
            case false:
                selectedList.removeAll(where: {$0.entityId == entity.entityId})
            case true:
                if !selectedList.contains(where: {$0.entityId == entity.entityId}) {
                    selectedList.append(entity)
                }
            }
        }
        .onAppear {
            if selectedList.contains(where: {$0.entityId == entity.entityId}) {
                selected = true
            }
        }
    }
}

struct RoomSetupView_Previews: PreviewProvider {
    static var previews: some View {
        RoomSetupView()
            .environmentObject(HAKitViewModel())
            .environmentObject(AppSettings())
    }
}
