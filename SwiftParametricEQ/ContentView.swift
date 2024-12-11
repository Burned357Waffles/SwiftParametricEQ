import SwiftUI

struct MainMenuView: View {
    @State private var navigateToArtists = false
    @State private var navigateToAlbums = false
    @State private var navigateToSongs = false
    @State private var navigateToInfo = false
    @State private var navigateToEQ = false
    @State private var searchQuery = ""
    
    @StateObject var fileHandler = FileHandler()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Main Menu Title
                Text("SwiftParametricEQ")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                    .padding(.top, 100.0)
                
                Divider().background(Color.white)
                
                /*
                 // Search
                 TextField("Search...", text: $searchQuery)
                     .padding()
                     .background(Color.black)
                     .cornerRadius(10)
                     .shadow(radius: 10)
                     .padding(.horizontal)
                     .foregroundColor(.white)
                     .onSubmit {
                         // search for song in dict
                         // show search results in new view
                     }
                     .overlay(
                         HStack {
                             Spacer()
                             Image(systemName: "magnifyingglass")
                                 .padding()
                                 .foregroundColor(.accentColor)
                         }
                     )
                     .border(/*@START_MENU_TOKEN@*/Color.gray/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                 */
                    
                Button(action: {
                    navigateToArtists = true
                }) {
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.white)
                            .font(.system(.title))
                        
                        Text("Artists")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
                .navigationDestination(isPresented: $navigateToArtists) {
                    ArtistsView()
                }
                .background(.black)
                
                Divider().background(Color.white)
                
                Button(action: {
                    navigateToAlbums = true
                }) {
                    HStack {
                        Image(systemName: "person.2.crop.square.stack")
                            .foregroundColor(.white)
                            .font(.system(.title))
                        
                        Text("Albums")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
                .navigationDestination(isPresented: $navigateToAlbums) {
                    AlbumsView(artist: nil)
                }
                
                Divider().background(Color.white)
                
                Button(action: {
                    navigateToSongs = true
                }) {
                    HStack {
                        Image(systemName: "music.note.list")
                            .foregroundColor(.white)
                            .font(.system(.title))
                        
                        Text("All Songs")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
                .navigationDestination(isPresented: $navigateToSongs) {
                    SongsView()
                }
                
                Divider().background(Color.white)
                
                Button(action: {
                    navigateToEQ = true
                }) {
                    HStack {
                        Image(systemName: "slider.vertical.3")
                            .foregroundColor(.white)
                            .font(.system(.title))
                        
                        Text("Equalizier")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
                .navigationDestination(isPresented: $navigateToEQ) {
                    EQView()
                }
                
                Divider().background(Color.white)
                
                Button(action: {
                    navigateToInfo = true
                }) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.white)
                            .font(.system(.title))
                        
                        Text("Information")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
                .navigationDestination(isPresented: $navigateToInfo) {
                    InfoView()
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .background(Color.black)
            .foregroundColor(.white)
            .edgesIgnoringSafeArea(.all)
        }.environmentObject(fileHandler)
    }
}


struct ArtistsView: View {
    @EnvironmentObject private var fileHandler: FileHandler
    @State private var selectedArtist: String? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToAlbums = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack(spacing: 40) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.white)
                            .font(.system(.title))
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Artists")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                    .padding(.top, 20)
                
                List(fileHandler.songsByArtist.keys.sorted(), id: \.self) { artist in
                    NavigationLink(destination: AlbumsView(artist: artist)) {
                        Text(artist)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .listRowBackground(Color.black)
                }
            }
            .background(Color.black)
            .listStyle(PlainListStyle())
            .onAppear {
                Task {
                    await fileHandler.organizeSongsByArtist()
                }
            }
        }
        .background(.black)
        .foregroundColor(.white)
        .navigationBarBackButtonHidden(true)
    }
}


struct AlbumsView: View {
    @EnvironmentObject private var fileHandler: FileHandler
    @State private var selectedAlbum: String? = nil
    @Environment(\.dismiss) private var dismiss
    
    private var artist: String?
    
    init(artist: String? = nil) {
        self.artist = artist
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 40) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.white)
                        .font(.system(.title))
                }
                Spacer()
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if artist == nil {
                Text("Albums")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                    .padding(.top, 20)
                
                listAllAlbums()
            } else {
                Text("\(artist ?? "Unknown Artist")")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                    .padding(.top, 20)
                listAlbumsOfArtist()
            }
        }
        .background(Color.black)
        .onAppear {
            Task {
                if artist == nil {
                    await fileHandler.organizeSongsByAlbum(selectedAlbum: nil)
                }
                else {
                    await fileHandler.organizeAlbumsByArtist(selectedArtist: artist ?? "Unknown Artist")
                }
            }
        }
        .foregroundColor(.white)
        .navigationBarBackButtonHidden(true)
    }
    
    private func listAllAlbums() -> some View {
        NavigationStack {
            List(fileHandler.songsByAlbum.keys.sorted(), id: \.self) { album in
                NavigationLink(destination: SongsView(album: album)) {
                    Button(action: {
                        selectedAlbum = album
                    }) {
                        HStack {
                            if let artwork = fileHandler.albumArtworks[album] {
                                Image(uiImage: artwork)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(5)
                            } else {
                                Color.gray
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(5)
                            }
                            
                            Text(album)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .background(Color.black)
                }
                .background(Color.black)
                .listRowBackground(Color.black)
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .listStyle(PlainListStyle())
        }
    }
    
    private func listAlbumsOfArtist() -> some View {
        NavigationStack {
            List(fileHandler.albumsByArtist.sorted(), id: \.self) { album in
                NavigationLink(destination: SongsView(album: album, artist: artist)) {
                    HStack {
                        if let artwork = fileHandler.albumArtworks[album] {
                            Image(uiImage: artwork)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .cornerRadius(5)
                        } else {
                            Color.gray
                                .frame(width: 50, height: 50)
                                .cornerRadius(5)
                                .background(Color.black)
                        }
                        
                        Text(album)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .background(Color.black)
                .listRowBackground(Color.black)
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .listStyle(PlainListStyle())
        }
    }

}


struct SongsView: View {
    @EnvironmentObject private var fileHandler: FileHandler
    @Environment(\.dismiss) private var dismiss
    
    private var album: String?
    private var artist: String?
    
    init(album: String? = nil, artist: String? = nil) {
            self.album = album
            self.artist = artist
        }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack(spacing: 40) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.white)
                            .font(.system(.title))
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if album == nil {
                    Text("All Songs")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                        .padding(.top, 20)
                    showAllSongs()
                }
                else {
                    if let artwork = fileHandler.currentArtworkImage{
                        Image(uiImage: artwork)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(5)
                    } else {
                        Color.gray
                            .scaledToFit()
                            .cornerRadius(5)
                            .background(Color.black)
                    }
                    
                    Text(album ?? "Unknown Album")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Text(fileHandler.currentArtist)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    
                    showSongsOfAlbum()
                }
            }
            .background(Color.black)
            .onAppear {
                Task {
                    if album == nil{
                        await fileHandler.organizeSongsByAlbum(selectedAlbum: nil)
                    }
                    else{
                        await fileHandler.organizeSongsOfAlbum(selectedAlbum: album ?? "Unknown Album")
                    }
                }
            }
        }
        .background(.black)
        .foregroundColor(.white)
        .navigationBarBackButtonHidden(true)
    }

    private func removeIndex(from title: String) -> String {
        let regex = try! NSRegularExpression(pattern: "^\\d+\\.\\s*")
        let range = NSRange(location: 0, length: title.utf16.count)
        return regex.stringByReplacingMatches(in: title, options: [], range: range, withTemplate: "")
    }
    
    private func showAllSongs() -> some View{
        NavigationStack {
            List(fileHandler.files.sorted {
                let title1 = removeIndex(from: $0.deletingPathExtension().lastPathComponent)
                let title2 = removeIndex(from: $1.deletingPathExtension().lastPathComponent)
                return title1.lowercased() < title2.lowercased()
            }, id: \.self) { file in
                NavigationLink(destination: PlayerView(songURL: file, startSong: true)){
                    let songTitle = removeIndex(from: file.deletingPathExtension().lastPathComponent)
                    Button(action: {
                        Task {
                            await fileHandler.loadCurrentSongMetadata(from: file)
                        }
                    }) {
                        Text(songTitle)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .listRowBackground(Color.black)
            }
            .background(Color.black)
            .listStyle(PlainListStyle())
        }
    }
    
    private func showSongsOfAlbum() -> some View{
        NavigationStack {
            List(fileHandler.songsOfAlbum, id: \.self) { song in
                NavigationLink(destination: PlayerView(songURL: getSongURL(for: song), startSong: true)){
                    Button(action: {
                        print("TODO: Play Song")
                    }) {
                        Text(song)
                            .foregroundColor(.white)
                            .padding()
                        
                    }
                }
                .listRowBackground(Color.black)
            }
            .background(Color.black)
            .listStyle(PlainListStyle())
        }
    }
    
    private func getSongURL(for song: String) -> URL? {
        for file in fileHandler.files {
            let fileName = file.deletingPathExtension().lastPathComponent
            if fileName == song {
                return file
            }
        }
        
        return nil
    }

}


struct InfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                HStack(spacing: 40) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.white)
                            .font(.system(.title))
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("App Information")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                    .padding(.top, 20)
                
                Text("Welcome to Swift Parametric Equalizer. This app was developed by Brandon Watanabe for CSC 780-01. With this app you can play your favorite downloaded songs and adjust a parametric equalizer to suit your headphones.")
                    .padding()
            }
        }.background(.black)
            .foregroundColor(.white)
            .navigationBarBackButtonHidden(true)
    }
}


struct PlayerView: View {
    @EnvironmentObject private var fileHandler: FileHandler
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToEQView = false
    @State private var hasStartedSong = false
    @State private var isPlaying: Bool = true
    @State private var selectedAlbum: String? = nil
    
    
    private var songURL: URL?
    private var startSong: Bool?
    
    init(songURL: URL? = nil, startSong: Bool? = false) {
        self.songURL = songURL
        self.startSong = startSong
    }
    
    var body: some View {
        NavigationStack { 
            GeometryReader { geometry in
                VStack {
                    // Top UI
                    HStack(spacing: 40) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.backward")
                                .foregroundColor(.white)
                                .font(.system(.title))
                        }
                        Spacer()
                        
                        Button(action: {
                            navigateToEQView = true
                        }) {
                            Image(systemName: "slider.vertical.3")
                                .foregroundColor(.white)
                                .font(.system(.title))
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Current song
                    VStack(spacing: 30.0) {
                        if let artwork = fileHandler.currentArtworkImage {
                            Image(uiImage: artwork)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaledToFit()
                                .frame(width: geometry.size.width, height: geometry.size.width)
                                .cornerRadius(20)
                                .shadow(radius: 10)
                        } else {
                            Image(systemName: "music.note")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding()
                                .frame(width: geometry.size.width, height: geometry.size.width)
                                .cornerRadius(20)
                                .shadow(radius: 10)
                                .background(.gray)
                        }
                        
                        // Song info
                        VStack(spacing: 8) {
                            Text(fileHandler.currentTitle)
                                .font(Font.system(.title).bold())
                            Text(fileHandler.currentArtist)
                                .font(.system(.headline))
                            Text(fileHandler.currentAlbum)
                                .font(.system(.subheadline))
                        }
                        .foregroundColor(.white)
                        
                        // Playback controls
                        HStack(spacing: 40) {
                            Button(action: {
                                print("Rewind")
                                Task{
                                    await fileHandler.playPrevious()
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .frame(width: 80, height: 80)
                                        .shadow(radius: 10)
                                    Image(systemName: "backward.fill")
                                        .foregroundColor(.black)
                                        .font(.system(.title))
                                }
                            }
                            
                            Button(action: {
                                if let currentSongURL = fileHandler.currentURL, !fileHandler.files.isEmpty {
                                    Task {
                                        await fileHandler.togglePlayback(from: currentSongURL, keepPlaying: false)
                                        isPlaying.toggle()
                                    }
                                } else {
                                    print("Error: currentSongURL is nil or no files available.")
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .frame(width: 80, height: 80)
                                        .shadow(radius: 10)
                                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                        .foregroundColor(.black)
                                        .font(.system(.title))
                                }
                            }
                            
                            Button(action: {
                                print("Skip")
                                Task{
                                    await fileHandler.playNext()
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .frame(width: 80, height: 80)
                                        .shadow(radius: 10)
                                    Image(systemName: "forward.fill")
                                        .foregroundColor(.black)
                                        .font(.system(.title))
                                }
                            }
                        }
                    }
                    .padding(.top, 50.0)
                    .onAppear {
                        if !fileHandler.files.isEmpty {
                            Task {
                                await fileHandler.organizeSongsByAlbum(selectedAlbum: nil)
                                await fileHandler.loadCurrentSongMetadata(from: songURL ?? URL(fileURLWithPath: ""))
                                if startSong == true && !hasStartedSong {
                                    hasStartedSong = true
                                    await fileHandler.togglePlayback(from: songURL ?? URL(fileURLWithPath: ""), keepPlaying: true)
                                }
                                await fileHandler.createPlayQueue(firstSong: songURL ?? URL(fileURLWithPath: ""))
                            }
                        }
                    }
                }
            }
            .background(.black)
            .navigationDestination(isPresented: $navigateToEQView) {
                EQView()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct EQView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var filters: [EQFilter] = []
    
    let filterTypes = ["peak", "low-shelf", "high-shelf"]
    
    private let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ""
        return formatter
    }()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Header
                HStack(spacing: 40) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.white)
                            .font(.system(.title))
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Filters List
                List {
                    HStack(spacing: 15) {
                        Text("Filter Type")
                            .foregroundColor(.white)
                            .frame(maxWidth: 100, alignment: .leading)
                        Text("Frequency")
                            .foregroundColor(.white)
                            .frame(maxWidth: 100, alignment: .leading)
                        Text("Q-Factor")
                            .foregroundColor(.white)
                            .frame(maxWidth: 100, alignment: .leading)
                        Text("Gain")
                            .foregroundColor(.white)
                            .frame(maxWidth: 100, alignment: .leading)
                    }
                    .padding(.top, 10)
                    .listRowBackground(Color.black)
                    
                    ForEach($filters.sorted(by: { $0.frequency.wrappedValue < $1.frequency.wrappedValue })) { $filter in
                        VStack(spacing: 20) {
                            HStack(spacing: 15) {
                                // Dropdown for Filter Type
                                Menu {
                                    ForEach(filterTypes, id: \.self) { type in
                                        Button(type) {
                                            filter.type = type
                                        }
                                    }
                                } label: {
                                    Text(filter.type)
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1))
                                }
                                
                                // Text Fields
                                TextField("Frequency", value: $filter.frequency, formatter: decimalFormatter)
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1))
                                    .frame(maxWidth: 100)
                                
                                TextField("Q-Factor", value: $filter.q, formatter: decimalFormatter)
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1))
                                    .frame(maxWidth: 100)
                                
                                TextField("Gain", value: $filter.gain, formatter: decimalFormatter)
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1))
                                    .frame(maxWidth: 100)
                            }
                        }
                        .listRowBackground(Color.black)
                    }
                    .onDelete(perform: deleteFilter)
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .background(Color.black)
                
                // Action Buttons
                HStack {
                    Button(action: addFilter) {
                        Text("Add Filter")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(5)
                    }
                    
                    Button(action: saveFilter) {
                        Text("Save Filters")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(5)
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadFilters()
        }
    }
    
    func addFilter() {
        filters.append(EQFilter(type: "peak", frequency: 1000, gain: 0, q: 1.41))
    }
    
    func deleteFilter(at offsets: IndexSet) {
        filters.remove(atOffsets: offsets)
    }
    
    func saveFilter() {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try jsonEncoder.encode(filters)
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("eq_profile.json")
            try jsonData.write(to: url)
            print("Filters saved to \(url)")
        } catch {
            print("Error saving filters: \(error)")
        }
    }
    
    func loadFilters() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("eq_profile.json")
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let savedFilters = try decoder.decode([EQFilter].self, from: data)
            filters = savedFilters
        } catch {
            print("Error loading filters: \(error)")
        }
    }
}


#Preview {
    MainMenuView()
    //EQView()
    //PlayerView()
}
