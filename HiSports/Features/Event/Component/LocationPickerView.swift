//
//  LocationPickerView.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 12/06/26.
//

import SwiftUI
import MapKit

struct LocationPickerView: View {
    // Menggunakan Binding untuk melempar nama lokasi kembali ke CreateEventView
    @Binding var selectedLocationName: String
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchManager = LocationSearchManagerViewModel()
    @State private var searchText = ""
    @State private var selectedPlacemark: MKMapItem?
    
    var body: some View {
        NavigationStack {
            VStack {
                if !searchText.isEmpty && !searchManager.searchResults.isEmpty {
                    List(searchManager.searchResults, id: \.self) { item in
                        Button(action: {
                            selectLocation(item)
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name ?? "Nama tidak diketahui")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(addressTitle(for: item))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .listStyle(.plain)
                } else {
                    // Tampilan default saat kolom pencarian kosong
                    ContentUnavailableView(
                        "Cari Lokasi",
                        systemImage: "mappin.and.ellipse",
                        description: Text("Ketik nama lapangan, stadion, atau alamat event.")
                    )
                }
            }
            .navigationTitle("Pilih Lokasi")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Cari tempat atau alamat...")
            .onChange(of: searchText) { _, newValue in
                Task {
                    await searchManager.searchPlaces(query: newValue)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Batal") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func selectLocation(_ item: MKMapItem) {
        selectedPlacemark = item
        let alamatLengkap = addressTitle(for: item)
        selectedLocationName = item.name ?? (alamatLengkap.isEmpty ? "Lokasi Tanpa Nama" : alamatLengkap)
        
        dismiss()
    }
    
    private func addressTitle(for item: MKMapItem) -> String {
        if #available(iOS 26.0, *) {
            return item.addressRepresentations?.fullAddress(includingRegion: true, singleLine: true) ?? ""
        } else {
            return item.placemark.title ?? ""
        }
    }
}

#Preview {
    LocationPickerView(selectedLocationName: .constant("Stadion Utama GBK"))
}
