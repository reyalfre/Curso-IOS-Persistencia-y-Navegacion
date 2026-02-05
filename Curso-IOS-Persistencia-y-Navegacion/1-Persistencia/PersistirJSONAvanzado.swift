//
//  PersistirJSONAvanzado.swift
//  Curso-IOS-Persistencia-y-Navegacion
//
//  Created by Equipo 8 on 5/2/26.
//

import SwiftUI

struct Persona: Codable {
    let nombre: String
    let edad: Int
    let email: String
}
let jsonString = """
    {
        "nombre" : "Pepe",
        "edad" : 55,
        "email" : "pepe@pepe.com"
    }
    """
let jsonArray = """
    [
            {
                "nombre" : "Pepe",
                "edad" : 55,
                "email" : "pepe@pepe.com"
            },
              {
                  "nombre" : "Pepe",
                  "edad" : 55,
                  "email" : "pepe@pepe.com"
              }
    ]
            
    """

struct Libro: Codable {
    let titulo: String
    let publicacion: Int?
}

struct Autor: Codable {
    let nombre: String
    let nacionalidad: String
    let libros: [Libro]
}

let jsonAutor = """
    {
        "nombre" : "Stephen King",
        "nacionalidad" : "USA",
        "libros" : [
            {
                "titulo" : "Misery",
                "publicacion" : 1987
            },
            {
                "titulo" : "It",
                "publicacion" : 1986
            }
        ]
    }

    """
struct PersistirJSONAvanzado: View {
    var body: some View {
        Text( /*@START_MENU_TOKEN@*/"Hello, World!" /*@END_MENU_TOKEN@*/)
            .onAppear {
                pruebasJSON()
            }
    }
    func pruebasJSON() {
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let persona = try JSONDecoder().decode(
                    Persona.self,
                    from: jsonData
                )
                print(persona)
            } catch {
                print("Error al decodificar: \(error)")
            }
        }

        if let jsonData = jsonArray.data(using: .utf8) {
            do {
                let personas: [Persona] = try JSONDecoder().decode(
                    [Persona].self,
                    from: jsonData
                )
                print(personas)
            } catch {
                print("Error al decodificar: \(error)")
            }
        }
        // 2. Corrige la decodificación en pruebasJSON()
        if let jsonData = jsonAutor.data(using: .utf8) {
            do {
                // Quitamos los corchetes: Autor.self en lugar de [Autor].self
                let autor: Autor = try JSONDecoder().decode(
                    Autor.self,
                    from: jsonData
                )
                print(autor)
            } catch {
                print("Error al decodificar Autor: \(error)")
            }
        }
    }
}

#Preview {
    PersistirJSONAvanzado()
}
