//
//  CompanyAllCell.swift
//  BeautyMasters
//
//  Created by Евгений Полтавец on 21/08/2024.
//

import SwiftUI
import SDWebImageSwiftUI
import MapKit

struct CompanyAllCell: View {
    
    @State var companyModel: Company_Model? = nil
    
    var body: some View {
        
        GeometryReader { geo in
            
            VStack {
                VStack(spacing: 0) {
                    if let image = companyModel?.image, let url = URL(string: image) {
                        WebImage(url: url)
                            .resizable()
                            .indicator(.activity)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.6)
                            .clipShape(.rect(topLeadingRadius: 60))
                    } else {
                        Image("ab1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.6)
                            .clipShape(.rect(topLeadingRadius: 42))
                    }
                    
                    
                    VStack {
                        
                        Group {
                            VStack(spacing: 8) {
                                
                                Text(companyModel?.companyName ?? "no found company")
                                    .font(.system(size: 24, weight: .heavy))
                                    .lineLimit(2)
                                
                                Text(companyModel?.description ?? "no description")
                                    .fontWeight(.medium)
                                    .lineLimit(10)
                                
                                HStack(spacing: 18) {
                                    Text(companyModel?.adress ?? "no adress")
                                        .font(.system(size: 18, weight: .heavy))
                                    .lineLimit(2)
                                    
                                    Button(action: { openInMaps()}) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundStyle(Color.blue.opacity(0.8))
                                    }
                                }

                                HStack {
                                    Image(systemName: "phone.circle.fill")
                                        .font(.system(size: 22))
                                    Text("\(companyModel?.phone ?? "no phone")")
                                }.onTapGesture {
                                    let phoneNumber = "tel://" + (companyModel?.phone ?? "no phone")
                                    if let url = URL(string: phoneNumber) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 20))
                                    Text(" \(companyModel?.email ?? "no email")")
                                }.truncationMode(.tail)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.6)
                    .background(.regularMaterial.opacity(0.7), in: .rect(bottomTrailingRadius: 42))

                }
                
            }.foregroundStyle(Color(hex: "F3E3CE"))
                .padding(.leading, 10)
        }.frame(height: 360)
            .padding(.bottom, 30)

    }
    
    private func openInMaps() {
        guard let longitude = companyModel?.longitude, let latitude = companyModel?.latitude else { return }
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
                mapItem.name = "We're here"
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving
                                                  ])
    }
}
