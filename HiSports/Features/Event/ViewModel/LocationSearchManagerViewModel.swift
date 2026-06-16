//
//  LocationSearchManagerViewModel.swift
//  HiSports
//
//  Created by Muhammad Ridwan Novriansyah on 12/06/26.
//

import SwiftUI
import Foundation
import MapKit

@Observable
class LocationSearchManagerViewModel {
    var searchResults: [MKMapItem] = []
    
    func searchPlaces(query: String) async {
        guard !query.isEmpty else {
            self.searchResults = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            await MainActor.run {
                self.searchResults = response.mapItems
            }
        } catch {
            print("Gagal mencari lokasi: \(error.localizedDescription)")
        }
    }
}
