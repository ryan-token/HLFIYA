//
//  SettingsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/6/22.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var storeManager: StoreManager
    
    @State private var isShowingAboutScreen = false
    @State private var isShowingPrivacyActionSheet = false
    @State private var isShowingError = false
    @State private var errorTitle = ""
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(named: "fuchsia")!]
    }
    
    var body: some View {
        NavigationView {
            Form {
                if storeManager.purchasedIds.isEmpty {
                    if let removeAdsProduct = storeManager.products.first {
                        AsyncButton(action: {
                            await purchaseRemoveAds(product: removeAdsProduct)
                        }) {
                            HStack {
                                Image(systemName: "star.square.fill")
                                    .font(Font.system(.title, design: .rounded))
                                    .foregroundColor(.green)
                                Text("Remove Ads for \(removeAdsProduct.displayPrice)")
                                    .font(Font.system(.body, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                
                Section(header: Text("Support")) {
                    Button(action: {
                        requestReviewManually()
                    }) {
                        HStack {
                            Image(systemName: "heart.square.fill")
                                .font(.title)
                                .foregroundColor(.red)
                            Text("Rate on the App Store")
                                .font(Font.system(.body, design: .rounded))
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                Section(header: Text("General")) {
                    Button(action: {
                        sendFeatureRequestEmail()
                    }) {
                        HStack {
                            Image(systemName: "bolt.square.fill")
                                .font(.title)
                                .foregroundColor(.mint)
                            Text("Feature Request")
                                .font(Font.system(.body, design: .rounded))
                                .foregroundColor(.primary)
                        }
                    }
                    .accessibilityLabel("Send an email with a feature request")
                    
                    Button(action: {
                        isShowingAboutScreen.toggle()
                    }) {
                        HStack {
                            Image(systemName: "person.crop.square.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                            Text("About")
                                .font(Font.system(.body, design: .rounded))
                                .foregroundColor(.primary)
                        }
                    }
                    .accessibilityLabel("About Hot Local Food In Your Area")
                    
                    Button(action: {
                        isShowingPrivacyActionSheet.toggle()
                    }) {
                        HStack {
                            Image(systemName: "lock.square.fill")
                                .font(.title)
                                .foregroundColor(.gray)
                            Text("Terms & Privacy Policy")
                                .font(Font.system(.body, design: .rounded))
                                .foregroundColor(.primary)
                        }
                    }
                    .accessibilityLabel("Terms of Use and Privacy Policy")
                    
                    .actionSheet(isPresented: $isShowingPrivacyActionSheet) {
                        ActionSheet(title: Text("Terms of Use and Privacy Policy"), buttons: [
                                .default(Text("Terms of Use")) {
                                    openTermsOfUseLink()
                                },
                                .default(Text("Privacy Policy")) {
                                    openPrivacyPolicyLink()
                                },
                                .cancel()
                            ]
                        )
                    }
                    .font(Font.system(.body, design: .rounded))
                }
                
                Section(header: Text("Stats")) {
                    NavigationLink(destination: SwipesStatsView()) {
                        HStack {
                            Image(systemName: "arrow.left.arrow.right.square.fill")
                                .font(.title)
                                .foregroundColor(.purple)
                            Text("Swipes")
                                .font(Font.system(.body, design: .rounded))
                        }
                    }
                }
                
                if !storeManager.purchasedIds.isEmpty {
                    Text("You paid to remove ads. Thank you!")
                        .font(Font.system(.body, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            
            .sheet(isPresented: $isShowingAboutScreen) {
                AboutView()
            }
            
            .alert(isPresented: $isShowingError, content: {
                Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("Okay")))
            })
            
            .navigationTitle("Settings")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        restorePurchases()
                    }) {
                        Text("Restore Purchases")
                            .font(Font.system(.body, design: .rounded))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Close")
                            .font(Font.system(.body, design: .rounded))
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    func requestReviewManually() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/us/app/outrank/id1621818779?action=write-review") else {
            fatalError("Expected a valid URL")
        }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
    
    func sendFeatureRequestEmail() {
        let email = "hotlocalfood@gmail.com"
        let subject = "Feature Request - HLFIYA"
                    
        let coded = "mailto:\(email)?subject=\(subject)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
        if let emailURL:NSURL = NSURL(string: coded!) {
            if UIApplication.shared.canOpenURL(emailURL as URL){
                UIApplication.shared.open(emailURL as URL)
            }
       }
    }
    
    func openPrivacyPolicyLink() {
        if let url = URL(string: "https://ryantoken.com/privacy-policy") {
            UIApplication.shared.open(url)
        }
    }
    
    func openTermsOfUseLink() {
        if let url = URL(string: "https://ryantoken.com/terms-of-use") {
            UIApplication.shared.open(url)
        }
    }
    
    func purchaseRemoveAds(product: Product) async {
        do {
            if try await storeManager.purchase(product) != nil {
                print("Purchase was successful")
            }
        } catch StoreError.failedVerification {
            HapticGenerator.playErrorHaptic()
            errorTitle = "Your purchase could not be verified by the App Store"
            isShowingError.toggle()
        } catch {
            HapticGenerator.playErrorHaptic()
            print("Failed purchase for \(product.id): \(error)")
        }
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(StoreManager())
    }
}
