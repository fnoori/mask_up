import SwiftUI
import CoreLocation

struct ManualAddressEntry: View {

    @Binding var latitude: Double
    @Binding var longitude: Double

    @Binding var address: String
    @Binding var street: String
    @Binding var unitNumber: String
    @Binding var postCode: String
    @Binding var city: String
    @Binding var provinceState: String
    @Binding var country: String

    @State var showAlert: Bool = false

    var body: some View {
        Group {
            TextField("Street", text: $street).disableAutocorrection(true)
            TextField("Unit Number", text: $unitNumber).disableAutocorrection(true).keyboardType(.numberPad)
            TextField("Post Code", text: $postCode).disableAutocorrection(true)
            TextField("City", text: $city).disableAutocorrection(true)
            TextField("Province/State", text: $provinceState).disableAutocorrection(true)
            TextField("Country", text: $country, onCommit: {
                let geoCoder = CLGeocoder()
                self.determineAddress()
                geoCoder.geocodeAddressString(self.address) { placemarks, error in
                    if error != nil {
                        self.showAlert = true
                    }

                    guard let placemarks = placemarks, let location = placemarks.first?.location else { return }

                    self.latitude = location.coordinate.latitude
                    self.longitude = location.coordinate.longitude

                    print("\nlat: \(self.latitude)")
                    print("\nlong: \(self.longitude)")
                }
            })
            .disableAutocorrection(true)
            .keyboardType(.webSearch)
        }.alert(isPresented: $showAlert) {
            Alert(title: Text("Invalid Address"), message: Text("Could not determine location based on the provided address, please make sure all the fields are accurate and populated."), dismissButton: .default(Text("OK")))
        }
    }

    func determineAddress() {
        var populatedAddress = ""

        if self.unitNumber != "" {
            populatedAddress += "\(self.unitNumber) - "
        }

        populatedAddress += "\(self.street), \(self.postCode), \(self.city), \(self.provinceState), \(self.country)"
        self.address = populatedAddress
    }
}
