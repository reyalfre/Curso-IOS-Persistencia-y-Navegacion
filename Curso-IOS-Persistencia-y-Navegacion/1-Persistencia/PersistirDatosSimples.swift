//
//  ContentView.swift
//  Curso-IOS-Persistencia-y-Navegacion
//
//  Created by Equipo 8 on 4/2/26.
//

import SwiftUI

//Opción 1 para tener constante usando enum (en este caso con ClaveStorage.ultimo_login)
enum ClaveStorage {
    static let ultimoLogin = "ultimo_login"
}

//Opcion 2 para tener constante usando extension (en este caso con .ultimoLogin)
/*extension String{
    static let ultimoLogin = "ultimo_login"
}
*/
struct PersistirDatosSimples: View {

    @AppStorage("usuario") private var nombreUsuario: String = "Invitado"
    @AppStorage("musicaActivada") private var musicaActivada: Bool = false

    @State private var ultimaFechaLogin = "Nunca"

    var body: some View {
        Form {
            Section("Datos de usuario (persistentes)") {
                // Persiste el valor automáticamente al modificarlo
                TextField("Tu nombre", text: $nombreUsuario)
                Toggle("Musica activada", isOn: $musicaActivada)
            }
            Section("Hora de acceso/registro") {
                Text("Último acceso: \(ultimaFechaLogin)")

                Button("Guardar fecha de login") {
                    guardarFechaLogin()
                }
                Button("Borrar fecha Login") {
                    borrarFechaLogin()
                }
            }
        }
        .onAppear {
            cargarFechaLogin()
        }
    }
    func guardarFechaLogin() {
        let fechaFormateada: String = Date().formatted(
            date: .abbreviated,
            time: .standard
        )  //Guardamos en UserDefaults
        UserDefaults.standard.set(
            fechaFormateada,
            forKey: ClaveStorage.ultimoLogin
        )

        ultimaFechaLogin = fechaFormateada
    }
    func cargarFechaLogin() {
        if let fechaLogin: String = UserDefaults.standard.string(
            forKey: ClaveStorage.ultimoLogin
        ) {
            ultimaFechaLogin = fechaLogin
        }
    }
    func borrarFechaLogin() {
        UserDefaults.standard.removeObject(forKey: ClaveStorage.ultimoLogin)
        ultimaFechaLogin = "Borrando registro de login"
    }
}

#Preview {
    PersistirDatosSimples()
}
