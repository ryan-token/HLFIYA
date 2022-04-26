//
//  BusinessView.swift
//  HLFIYA
//
//  Created by Ryan Token on 4/24/22.
//

import SwiftUI

struct BusinessView: View {
    @State private var currentBusiness = BusinessDetails()
    @State private var apiError = false
    
    @Environment(\.dismiss) var dismiss
    
    var business: Business
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Button("Dismiss") {
                    dismiss()
                }
            }
            .padding()
            
            Spacer()
            
            if apiError {
                Text("😕 Error loading businesses")
                    .foregroundColor(.gray)
                    .padding(.leading)
            }
            
            List {
                Section(header: Text(currentBusiness.name ?? "")) {
                    StarRatingView(rating: currentBusiness.rating ?? 0.0)
                }
                .headerProminence(.increased)
                
                Section(header: Text("Categories")) {
                    ForEach(currentBusiness.categories ?? [BusinessDetails.Category(alias: "", title: "")], id: \.self) { category in
                        Text(category.title ?? "")
                    }
                }
                
                Section(header: Text("Photos")) {
                    ImageSliderView(imageUrls: currentBusiness.photos ?? [""])
                        .frame(height: 300)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
            }
            
            Spacer()
        }
        
        .task {
            await getBusiness(id: business.id)
        }
    }
    
    func getBusiness(id: String) async {
        Task {
            do {
                let businessDetails = try await BusinessFetcher.getBusiness(id: id)
                currentBusiness = businessDetails
                print(businessDetails)
                apiError = false
            } catch {
                print("Request failed with error: \(error)")
                apiError = true
            }
        }
    }
}

struct BusinessView_Previews: PreviewProvider {
    static var previews: some View {
        BusinessView(business: Business.data[0])
    }
}
