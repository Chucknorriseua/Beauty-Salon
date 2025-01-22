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
    @State var isShow: Bool = false
    let onToggle: ()->()
    
    var body: some View {
        
        GeometryReader { geo in
            VStack {
                if isShow {
                    VStack {
                        VStack(spacing: -18) {
                            if let image = companyModel?.image, let url = URL(string: image) {
                                WebImage(url: url)
                                    .resizable()
                                    .indicator(.activity)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.6)
                                    .clipShape(.rect(cornerRadius: 22))
                            } else {
                                Image("ab1")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.6)
                                    .clipShape(.rect(cornerRadius: 24))
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
                                            .truncationMode(.tail)
                                            .multilineTextAlignment(.leading)
                                        HStack {
                                            VStack(alignment: .leading, spacing: 6) {
                                                
                                                HStack(spacing: 0) {
                                                    Text(companyModel?.adress ?? "no adress")
                                                        .font(.system(size: 18, weight: .heavy))
                                                        .lineLimit(2)
                                                    
                                                }
                                                
                                                HStack {
                                                    Image(systemName: "phone.circle.fill")
                                                        .resizable()
                                                        .foregroundStyle(Color.green.opacity(0.8))
                                                        .frame(width: 20, height: 20)
                                                    Text("\(companyModel?.phone ?? "no phone")")
                                                }.onTapGesture {
                                                    let phoneNumber = "tel://" + (companyModel?.phone ?? "no phone")
                                                    if let url = URL(string: phoneNumber) {
                                                        UIApplication.shared.open(url)
                                                    }
                                                }
                                                HStack {
                                                    Image(systemName: "envelope.fill")
                                                        .resizable()
                                                        .frame(width: 20, height: 14)
                                                    Text("\(companyModel?.email ?? "no email")")
                                                }
                                            }
                                            Spacer()

                                        }.padding(.leading, 6)
                                    }
                                }
                            }
                            .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.6)
                            .background(.regularMaterial.opacity(0.3))
                            .clipShape(.rect(cornerRadius: 22))
                            .overlay(alignment: .bottomTrailing) {
                                
                                Button(action: { openInMaps()}) {
                                    VStack {
                                        Image(systemName: "location.fill.viewfinder")
                                            .font(.system(size: 34))
                                            .foregroundStyle(Color.blue.opacity(0.8))
                                    }
                                }.padding([.horizontal, .vertical], 10)
                            }
                        }
                        
                    }.foregroundStyle(Color.white)
                        .padding(.leading, 10)
                } else {
                    VStack {
                        VStack {
                            if let image = companyModel?.image, let url = URL(string: image) {
                                WebImage(url: url)
                                    .resizable()
                                    .indicator(.activity)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.36)
                                    .clipShape(.rect(cornerRadius: 24))
                            } else {
                                Image("ab1")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.36)
                                    .clipShape(.rect(cornerRadius: 24))
                            }
                        
                        }.overlay(alignment: .bottom) {
                            ZStack {
                                Text(companyModel?.companyName ?? "no found company")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(Color.white)
                            }
                        }
                    }.padding(.leading, 8)
                }
            }.overlay(alignment: .topTrailing) {
                ZStack {
                    Button {
                        withAnimation(.linear(duration: 0.5)) {
                            onToggle()
                            isShow.toggle()
                        }
                    } label: {
                        Image(systemName: isShow ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color.yellow.opacity(0.8))
                    }
                }.padding([.horizontal, .vertical], 10)
            }
        }.frame(height: !isShow ? 240 : 360)
            .padding(.bottom, !isShow ? -150 : 30)
        
    }

    
    private func openInMaps() {
        guard let longitude = companyModel?.longitude, let latitude = companyModel?.latitude else { return }
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
        mapItem.name = "We're here"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving
                                          ])
    }
}
#Preview {
    CompanyAllCell(companyModel: Company_Model.companyModel(), isShow: false, onToggle: {})
}
