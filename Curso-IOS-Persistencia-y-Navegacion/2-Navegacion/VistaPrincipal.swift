//
//  VistaPrincipal.swift
//  Curso-IOS-Persistencia-y-Navegacion
//
//  Created by Equipo 8 on 5/2/26.
//

import Observation
import SwiftUI

enum Destino: Hashable {
    case detalle(String)
    case numero(Int)
    case ajustes
}
@Observable
class Router {
    var path = NavigationPath()

    func navigate(to destination: Destino) {
        path.append(destination)
    }
    func popRoute() {
        path.removeLast()
    }
    func popToRoot() {
        path = NavigationPath()
    }
}

fileprivate struct VistaPrincipal: View {

    @Environment(Router.self) private var router
    var body: some View {
        @Bindable var bindingRouter = router

        NavigationStack(path: $bindingRouter.path) {
            VStack(spacing: 10) {
                Button("Ir a vista detalle") {
                    router.navigate(to: .detalle("Detalle_1"))
                }
                Button("Ir a vista número") {
                    let numero = Int.random(in: 1...100)
                    router.navigate(to: .numero(numero))
                }
                Button("Ir a ajustes") {
                    router.navigate(to: .ajustes)
                }
            }
            .navigationDestination(for: Destino.self) {
                destino in
                switch destino {
                case .detalle(let id):
                    VistaDetalle(id: id)
                case .numero(let numero):
                    VistaNumero(numero: numero)
                case .ajustes:
                    VistaAjustes()
                }
            }

        }
        .onAppear {
            print(router.path)
        }
    }
}
struct VistaDetalle: View {
    @Environment(Router.self) var router
    let id: String
    var body: some View {
        Text("Id de la vista: \(id)")

        Button("Ve a vista detalle \(router.path.count + 1)") {
            router.navigate(to: .detalle("Detalle_\(router.path.count + 1)"))
        }

        Button("Volver a un nivel") {
            router.popRoute()
        }
        Button("Volver al inicio") {
            router.popToRoot()
        }
        .onAppear {
            print("Soy la vista \(id)")
            print(router.path)
        }
    }
}
struct VistaNumero: View {
    @Environment(Router.self) var router
    let numero: Int

    var body: some View {
        VStack {
            Text("Número: \(numero)")
                .font(.largeTitle)
                .foregroundStyle(.blue.opacity(0.2))
            Button("Volver") {
                router.popRoute()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Vista Número")
    }
}
struct VistaAjustes: View {
    @Environment(Router.self) var router

    var body: some View {
        VStack {
            Toggle("Notificaciones", isOn: .constant(true))

            Button("Guardar y cerrar") {
                router.popRoute()
            }
        }
        .navigationTitle("Ajustes")
    }
}

#Preview {
    VistaPrincipal()
        .environment(Router())
}
