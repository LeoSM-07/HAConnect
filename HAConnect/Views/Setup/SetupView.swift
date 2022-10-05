//
// SetupView.swift
// HAConnect
//
// Created by LeoSM_07 on 10/4/22.
//

import SwiftUI

struct SetupView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appSettings: AppSettings
    
    @State var internalURLField: String = "http://homeassistant.local:8123/"
    @State var externalURLField: String = ""
    @State var useExternalOnly: Bool = false
    @State var tokenField: String = ""
    @State var wifiKeywordField: String = ""
    
    @State var isCheckingFields = false
    @State var errorMessage = ""
    @State var showErrorAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("HomeAssistant Server") {
                    urlInput(prompt: "Interal URL", text: $internalURLField, internalURLField)
                    urlInput(prompt: "External URL (Optional)", text: $externalURLField, externalURLField)
                    Toggle("Only Use External URL", isOn: $useExternalOnly)
                }
                
                Section() {
                    SecureField("Token", text: $tokenField, prompt: Text("Token"))
                } header: {
                    Text("Long-Lived Access Token")
                } footer: {
                    Text("You can generate long-lived access tokens from your personal HomeAssistant profile")
                }
                
                if !useExternalOnly {
                    Section() {
                        TextField("Keyword", text: $wifiKeywordField, prompt: Text("Keyword"))
                    } header: {
                        Text("Wifi Keyword")
                    } footer: { Text("Your WiFi keyword is used to determine if you should use your Internal or External URL. When you are connected to Wifi and your Wifi name contains they keyword, the local URL will be used.\n**For example if your Wifi networks are named:**\n\n• Cosmos\n• Cosmos-5G\n• Cosmos-5G-2\n\nYour Wifi keyword would be **Cosmos** because it is included in all your local network names.") }
                }
            }
            .onChange(of: errorMessage, perform: { newValue in
                if newValue != "" {
                    showErrorAlert = true
                }
            })
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: Alert.Button.default(
                        Text("OK"), action: {
                            errorMessage = ""
                            isCheckingFields = false

                        }
                    )
                )
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if isCheckingFields {
                        ProgressView()
                    } else {
                        Button("Done") {
                            checkFields()
                        }
                    }

                }
            }
            .tint(.accentColor)
            .navigationTitle("Connect HA")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    
    @ViewBuilder
    func urlInput(prompt: String, text: Binding<String>, _ t: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(prompt)
                .foregroundColor(.secondary)
                if t != "" {
                    Image(systemName: t.isValidURL ? "checkmark" : "xmark")
                        .foregroundColor(t.isValidURL ? .green : .red)
                        .bold()
                }

            }
            .font(.footnote)
            TextField(prompt, text: text, prompt: Text("URL"))
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
        }
    }
    
    func checkFields() {
        print("Current error: \(errorMessage)")
        isCheckingFields = true
        if !internalURLField.isValidURL {
            errorMessage = "Internal URL is invalid!"
            print(errorMessage)
            return
        } else if !externalURLField.isValidURL && externalURLField != "" {
            errorMessage = "External URL is invalid!"
            print(errorMessage)
            return
        } else if tokenField == "" {
            errorMessage = "Long-lived access Token is blank!"
            print(errorMessage)
            return
        } else {
            checkSession(url: internalURLField) { result in
                if result == "REQUEST_TIMEOUT"{
                    errorMessage = "The Internal URL timed out."
                    print(errorMessage)
                    return
                } else if result == "CONNECTION_ERROR" {
                    errorMessage = "Could not connect to Internal URL."
                    print(errorMessage)
                    return
                } else if result == "INVALID_TOKEN" {
                    errorMessage = "Token was not valid"
                    print(errorMessage)
                    return
                } else {
                    if externalURLField != "" {
                        checkSession(url: externalURLField) { result in
                            if result == "REQUEST_TIMEOUT"{
                                errorMessage = "The External URL timed out."
                                print(errorMessage)
                                return
                            } else if result == "CONNECTION_ERROR" {
                                errorMessage = "Could not connect to External URL."
                                print(errorMessage)
                                return
                            } else if result == "INVALID_TOKEN" {
                                errorMessage = "Token was not valid"
                                print(errorMessage)
                                return
                            } else {
                                print("SETTINGS CONFIRMED")
                                appSettings.internalURL = internalURLField
                                appSettings.externalURL = externalURLField
                                appSettings.token = tokenField
                                appSettings.wifiKeyword = wifiKeywordField
                                appSettings.externalURLOnly = useExternalOnly
                                isCheckingFields = false
                                dismiss()
                                return
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView()
    }
}
