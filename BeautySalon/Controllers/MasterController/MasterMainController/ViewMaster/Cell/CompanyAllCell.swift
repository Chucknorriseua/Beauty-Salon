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
    @State var isShowLike: Bool = false
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
                                    VStack(alignment: .center) {
                                        Text(companyModel?.companyName ?? "no found company")
                                            .font(.system(size: 24, weight: .heavy))
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(.top, 20)
                               
                                    VStack(alignment: .leading) {
                                        VStack(alignment: .leading) {
                                            Text(companyModel?.description ?? "no description")
                                                .font(.system(size: 16, weight: .heavy))
                                                .lineLimit(10)
                                                .multilineTextAlignment(.leading)
                                                .truncationMode(.tail)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 200)
                                        
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(companyModel?.adress ?? "no adress")
                                                .font(.system(size: 18, weight: .heavy))
                                            
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
                                            Spacer()
                                        }
                                    }
                                
                                }
                                .padding(.horizontal, 6)
                            }
                            .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.84)
                            .background(.regularMaterial.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.yellow, .gray]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 4
                                    )
                            )
                            .clipShape(.rect(cornerRadius: 22))
                            .overlay(alignment: .bottomTrailing) {
                                HStack(spacing: 20) {
                                    if isShowLike {
                                        Button(action: {
                                            Task {
                                                do {
                                                    try await Client_DataBase.shared.favoritesLikes(salonID: companyModel?.id ?? "", userID: ClientViewModel.shared.clientModel.id)
                                                } catch {
                                                    print(error.localizedDescription)
                                                }
                                            }
                                        }) {
                                            Image(systemName: "heart.fill")
                                                .foregroundStyle(Color.red)
                                                .font(.system(size: 32))
                                              
                                        }
                         
                                        .overlay(alignment: .bottom) {
                                            HStack(spacing: 0) {
                                                Image(systemName: "smiley")
                                                    .foregroundStyle(Color.yellow)
                                                Text("+\(companyModel?.likes ?? 0)")
                                                    .foregroundStyle(Color.white)
                                                    .fontWeight(.bold)
                                            }
                                            .frame(width: 80)
                                            .offset(x: -14, y: 18)
                                        }
                                    }
                                    Button(action: {
                                        guard let salon = companyModel else { return}
                                        Task {
                                            await ClientViewModel.shared.addMyFavoritesSalon(salon: salon)
                                        }
                                    }) {
                                        VStack {
                                            Image(systemName: "star.square.fill")
                                                .font(.system(size: 38))
                                                .foregroundStyle(Color.yellow)
                                        }
                                    }
                                    
                                    Button(action: { openInMaps()}) {
                                        VStack {
                                            Image(systemName: "location.fill.viewfinder")
                                                .font(.system(size: 34))
                                                .foregroundStyle(Color.blue.opacity(0.8))
                                        }
                                    }
                                }
                                .padding([.horizontal, .vertical], 10)
                                .padding(.bottom, 16)
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
            }
            .overlay(alignment: .topTrailing) {
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
                            .foregroundStyle(Color.yellow)
                    }
                }.padding([.horizontal, .vertical], 10)
            }
        }
        .frame(height: isShow ? 340 : 250)
        .padding(.bottom, isShow ? 140 : -124)
        
    }
    
    
    private func openInMaps() {
        guard let longitude = companyModel?.longitude, let latitude = companyModel?.latitude else { return }
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
        mapItem.name = "We're here"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving
                                          ])
    }
}

#Preview(body: {
    CompanyAllCell(companyModel: Company_Model(id: "", adminID: "", name: "Anna", companyName: "Sun-Shine", adress: "ul.matlahova 1a", email: "qwe@gmail.com", phone: "+095-091-26-27", description: "If you’re just starting up your app or if you don’t already have a pipeline, I strongly suggest you use Xcode Cloud. In the past I’ve done it using Fastlane and the setup part was way too complex having to deal with provisioning profiles, environment setups, and much more", image: "", procedure: [], likes: 50, fcnTokenUser: "", latitude: 0.0, longitude: 0.0, categories: ""), isShow: false, isShowLike: true, onToggle: {})
})
