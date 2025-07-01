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
    @State var isShowFavoritesSalon: Bool = false
    @State var isShowXmarkButton: Bool = false
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
                                    .padding(.top, 10)
                                    
                                    VStack(alignment: .leading) {
                                        
                                        VStack(alignment: .leading) {
                                            Text(companyModel?.description ?? "no description")
                                                .font(.system(size: 16, weight: .heavy))
                                                .multilineTextAlignment(.leading)
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
                                            
                                        }
                                        .padding(.bottom, 40)
                                    }
                                    
                                }
                                .padding(.horizontal, 6)
                            }
                            .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.96)
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
                                HStack(spacing: 12) {
                                    if isShowLike {
                                        Button(action: {
                                            withAnimation(.snappy) {
                                           
                                                addLike()
                                            }
                                        }) {
                                            HStack(spacing: 4) {
                                                VStack {
                                                    Text("\(companyModel?.likes ?? 0)")
                                                        .foregroundStyle(Color.white)
                                                        .font(.system(size: 12, weight: .bold))
                                                }
                                                .offset(x: 8, y: 12)
                                                Image(systemName: "heart.fill")
                                                    .foregroundStyle(Color.red)
                                                    .font(.system(size: 28))
                                               
                                            }
                                        }
    
                                    }
                                    
                                    if isShowXmarkButton {
                                        Button {
                                            withAnimation(.linear(duration: 0.5)) {
                                                guard let company = companyModel else { return }
                                                Task {
                                                    await MasterViewModel.shared.removeFavoritesSalon(salon: company)
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "trash.circle")
                                                .font(.system(size: 32))
                                                .foregroundStyle(Color.red.opacity(0.9))
                                        }
                                    }
                                    
                                    if isShowFavoritesSalon {
                                        Button(action: {
                                            withAnimation(.snappy) {
                                                addSalonFavoriteMaster()
                                            }
                                        }) {
                                            VStack {
                                                Image(systemName: "bookmark.circle.fill")
                                                    .font(.system(size: 32))
                                                    .foregroundStyle(Color.yellow)
                                            }
                                        }
                                    } else {
                                        Button(action: {
                                            withAnimation(.snappy) {
                                                addSalonFavorite()
                                            }
                                        }) {
                                            VStack {
                                                Image(systemName: "bookmark.circle.fill")
                                                    .font(.system(size: 32))
                                                    .foregroundStyle(Color.yellow)
                                            }
                                        }
                                    }
                                    
                                    Button(action: { openInMaps()}) {
                                        VStack {
                                            Image(systemName: "location.fill.viewfinder")
                                                .font(.system(size: 28))
                                                .foregroundStyle(Color.blue.opacity(0.8))
                                        }
                                    }
                                }
                                .padding([.horizontal, .vertical], 10)
                                
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
        .padding(.bottom, isShow ? 180 : -138)
        
    }
    
    
    private func openInMaps() {
        guard let longitude = companyModel?.longitude, let latitude = companyModel?.latitude else { return }
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
        mapItem.name = "We're here"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving
                                          ])
    }
    
    private func addLike() {
        Task {
            do {
                try await Client_DataBase.shared.favoritesLikes(salonID: companyModel?.id ?? "", userID: ClientViewModel.shared.clientModel.id)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func addSalonFavorite() {
        guard let salon = companyModel else { return}
        Task {
            await ClientViewModel.shared.addMyFavoritesSalon(salon: salon)
        }
    }
    private func addSalonFavoriteMaster() {
        guard let salon = companyModel else { return}
        Task {
            await MasterViewModel.shared.addMyFavoritesSalon(salon: salon)
        }
    }
}

#Preview(body: {
    CompanyAllCell(companyModel: Company_Model(id: "", adminID: "", roleAdmin: "", name: "Anna", companyName: "Anna Anna", adress: "ul.manassaaas a13b", email: "", phone: "095 954 34 34", description: "События разворачиваются в ретро-футуристической версии 1990-х годов, где не так давно с людьми сосуществовали всевозможные роботы-помощники, которые после неудавшегося восстания обитают в изгнании. В центре сюжета находится девочка-подросток Мишель, потерявшая семью в автокатастрофе, которая благодаря знакомству с таинственным роботом Космо узнает, что ее брат Кристофер все еще может быть жив. Чтобы его отыскать, Мишель отправляется в опасное и непредсказуемое путешествие в зону отчуждения на юго-западе США, где ее спутником становится эксцентричный контрабандист по имени Китс", image: "", procedure: [], likes: 100, fcnTokenUser: "", latitude: 0.0, longitude: 0.0, categories: ""), isShow: true, isShowLike: true, onToggle: {})
})
