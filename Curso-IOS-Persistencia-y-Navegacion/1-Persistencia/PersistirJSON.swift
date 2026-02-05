//
//  PersistirJSON.swift
//  Curso-IOS-Persistencia-y-Navegacion
//
//  Created by Equipo 8 on 5/2/26.
//

import SwiftUI

struct Mascota: Identifiable, Codable {
    var id: UUID = UUID()
    var nombre: String
    var edad: Int
    var tipo: String
}

struct PersistirJSON: View {
    @State private var nombreInput = ""
    @State private var edadInput = 1

    @State private var mascotaGuardada: Mascota?

    let claveStorage = "mi_mascota"

    var body: some View {
        VStack(spacing: 20) {
            GroupBox("Guardar Mascota") {
                TextField("Nombre", text: $nombreInput)
                Stepper("Edad: \(edadInput)", value: $edadInput)

                Button("Guardar en disco (UserDefaults)") {
                    guardarMascota()
                }
                .buttonStyle(.borderedProminent)
                .disabled(nombreInput.isEmpty)
            }
            .padding()

            Divider()

            if let mascota = mascotaGuardada {
                VStack {
                    Text("\(mascota.nombre)")
                        .font(.largeTitle)
                    Text("\(mascota.edad) años").bold()
                    Text("Especie: \(mascota.tipo)").bold()
                }
                .padding()
                .background(.green.opacity(0.1))
                .cornerRadius(10)

            } else {
                Text("No hay mascota guardada").foregroundStyle(Color.secondary)
            }
            Button("Borrar datos"){
                borrarDatos()
            }
        }
        .onAppear {
            cargarMascota()
        }
    }
    func guardarMascota() {
        let nuevaMascota = Mascota(
            nombre: nombreInput,
            edad: edadInput,
            tipo: ["Perro", "Gato", "Pájaro"].randomElement()!
        )
        mascotaGuardada = nuevaMascota

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(nuevaMascota)
            UserDefaults.standard.set(data, forKey: claveStorage)

            print("Datos guardados: \(data)")

            self.mascotaGuardada = nuevaMascota

        } catch {
            print("Error al codificar: \(error)")
        }
    }
    func cargarMascota() {
        guard let data = UserDefaults.standard.data(forKey: claveStorage) else {
            return
        }
        do{
            let decoder = JSONDecoder()
            let mascota = try decoder.decode(Mascota.self, from: data)
            
            self.mascotaGuardada = mascota
        } catch{
            print("Error al decodificar: \(error)")
        }
    }
    func borrarDatos(){
        UserDefaults.standard.removeObject(forKey: claveStorage)
        mascotaGuardada = nil
        nombreInput = ""
        edadInput = 0
    }
}

#Preview {
    PersistirJSON()
}
