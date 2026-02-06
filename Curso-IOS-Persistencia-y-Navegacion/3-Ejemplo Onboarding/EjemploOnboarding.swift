//
//  EjemploOnboarding.swift
//  Curso-iOS-Persistencia-y-Navegacion
//
//  Created by Equipo 8 on 6/2/26.
//

import SwiftUI

struct Usuario: Codable, Equatable {
    let nombreUsuario: String
    let password: String  // No usar así en una app real
}
struct Item: Identifiable, Codable {
    var id = UUID()
    let titulo: String
    var fechaAnadido = Date()
}

@Observable
class AppManager {

    enum EstadoApp {
        case onboarding
        case auth  // Alta nuevo usuario o login
        case principal
    }

    var items: [Item] = []
    var usuarioActual: Usuario?
    var haVistoOnboarding: Bool = false

    var pantallaActual: EstadoApp {
        if !haVistoOnboarding { return .onboarding }
        if usuarioActual == nil { return .auth }
        return .principal
    }

    // Constantes de claves para UserDefaults
    private let claveOnboarding = "ha_visto_onboarding"
    private let claveUsuario = "usuario_guardado"
    private let claveItems = "items_guardados"

    init() {
        cargarDatos()
    }

    private func cargarDatos() {
        haVistoOnboarding = UserDefaults.standard.bool(forKey: claveOnboarding)

        //Cargar usuario si existe
        if let data = UserDefaults.standard.data(forKey: claveUsuario),
            let usuario = try? JSONDecoder().decode(Usuario.self, from: data)
        {
            self.usuarioActual = usuario
        }
        // Cargar items de usuario si los tiene o están vacíos []
        if let data = UserDefaults.standard.data(forKey: claveItems),
            let itemsGuardados = try? JSONDecoder().decode(
                [Item].self,
                from: data
            )
        {
            self.items = itemsGuardados
        }
    }

    func terminarOnboarding() {
        haVistoOnboarding = true
        UserDefaults.standard.set(haVistoOnboarding, forKey: claveOnboarding)
    }

    func registrarOIniciarSesion(nombreUsuario: String, pass: String) {
        let nuevoUsuario = Usuario(nombreUsuario: nombreUsuario, password: pass)
        usuarioActual = nuevoUsuario

        if let data = try? JSONEncoder().encode(nuevoUsuario) {
            UserDefaults.standard.set(data, forKey: claveUsuario)
        }
    }
    func anadirItem(titulo: String) {
        let nuevoItem = Item(titulo: titulo)
        items.append(nuevoItem)
        persistirItems()
    }
    func borrarTodosItems() {
        items.removeAll()
        persistirItems()
    }
    private func persistirItems() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: claveItems)
        }
    }
}

@main
struct AppOnboarding: App {
    // Instanciar AppManager
    @State private var manager = AppManager()

    var body: some Scene {
        WindowGroup {
            SelectorDeVista()
                .environment(manager)
        }
    }
}

struct SelectorDeVista: View {
    @Environment(AppManager.self) var manager

    var body: some View {
        // Necesitamos Group como contenedor para poder aplicar el .animation a todas las vistas
        Group {
            switch manager.pantallaActual {
            case .onboarding:
                VistaOnboarding()
            case .auth:
                VistaAuth()
            case .principal:
                VistaPrincipal()
            }
        }
        .animation(.easeOut, value: manager.pantallaActual)
    }
}

private struct VistaPrincipal: View {
    @Environment(AppManager.self) var manager
    @State private var nuevoItemText = ""
    var body: some View {
        NavigationStack {
            List {
                Section("Añadir") {
                    HStack {
                        TextField("Nuevo articulo...", text: $nuevoItemText)

                        Button {
                            guard !nuevoItemText.isEmpty else { return }
                            manager.anadirItem(titulo: nuevoItemText)
                            nuevoItemText = ""
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }

                    }
                }
                Section("Mis artículos") {
                    if manager.items.isEmpty {
                        Text("No hay artículos guardados")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(manager.items) { item in
                            HStack {
                                Text(item.titulo)
                                Spacer()
                                Text(item.fechaAnadido, style: .time)
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                }

            }
            .navigationTitle("Hola, \(manager.usuarioActual!.nombreUsuario)")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: VistaSettings()) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}
struct VistaSettings: View {
    @Environment(AppManager.self) var manager
    @State private var mostrarOnboarding = false

    var body: some View {
        Form {
            Section("General") {
                Button("Ver onboarding de nuevo") {
                    mostrarOnboarding = true
                }
            }

        }
        .navigationTitle("Ajustes")
        .sheet(isPresented: $mostrarOnboarding) {
            ZStack(alignment: .topTrailing) {
                VistaOnboarding()
                Button {
                    mostrarOnboarding = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .padding()
                }
            }
        }
    }
}

struct VistaOnboarding: View {
    @Environment(AppManager.self) var manager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        TabView {
            crearPagina(
                color: .blue,
                titulo: "Bienvenido/a",
                desc: "Esta es la app de prácticas"
            )
            crearPagina(
                color: .green,
                titulo: "Sin trampa ni cartón",
                desc: "Aplicación 100% gratuita"
            )
            crearPagina(
                color: .orange,
                titulo: "¡Empecemos!",
                desc: "Crea tu cuenta ahora",
                esUltima: true
            )
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .ignoresSafeArea()
    }

    func crearPagina(
        color: Color,
        titulo: String,
        desc: String,
        esUltima: Bool = false
    ) -> some View {
        ZStack {
            color
            VStack(spacing: 20) {
                Text(titulo)
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.white)

                Text(desc)
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.8))

                if esUltima {
                    Button("Entendido") {
                        withAnimation {
                            manager.terminarOnboarding()
                            dismiss()
                        }
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(10)
                    .padding(.top, 50)
                }
            }
            .padding()
        }
        .ignoresSafeArea()
    }
}

struct VistaAuth: View {

    @Environment(AppManager.self) var manager

    @State private var nombreUsuario = ""
    @State private var password = ""
    @State private var mostrarError = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Iniciar Sesión / Registro")
                .font(.title)
                .bold()

            TextField("Usuario", text: $nombreUsuario)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)

            SecureField("Contraseña", text: $password)
                .textFieldStyle(.roundedBorder)

            if mostrarError {
                Text("Por favor rellena ambos campos")
                    .foregroundStyle(.red)
            }

            Button("Acceder") {
                if nombreUsuario.isEmpty || password.isEmpty {
                    mostrarError = true
                } else {
                    mostrarError = false
                    manager.registrarOIniciarSesion(
                        nombreUsuario: nombreUsuario,
                        pass: password
                    )
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview("1. Onboarding") {
    let manager = AppManager()
    manager.haVistoOnboarding = false
    manager.usuarioActual = nil

    return SelectorDeVista()
        .environment(manager)
}

#Preview("2. Login") {
    let manager = AppManager()
    manager.haVistoOnboarding = true
    manager.usuarioActual = nil

    return SelectorDeVista()
        .environment(manager)
}

#Preview("3. Página principal") {
    let manager = AppManager()
    manager.haVistoOnboarding = true
    manager.usuarioActual = Usuario(nombreUsuario: "Pepe", password: "xxxx")
    //    manager.items = [
    //        Item(titulo: "Mantequilla"),
    //        Item(titulo: "Mi libro de SwiftUI"),
    //    ]

    return SelectorDeVista()
        .environment(manager)
}

#Preview("4. Vista Ajustes") {
    let manager = AppManager()
    manager.usuarioActual = Usuario(nombreUsuario: "Pepe", password: "asdf")

    return NavigationStack {
        VistaSettings()
            .environment(manager)
    }
}
