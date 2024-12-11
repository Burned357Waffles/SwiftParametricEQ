import SwiftUI
import AudioKit
import SoundpipeAudioKit
import AVFoundation
import Foundation

struct EQFilter: Codable, Identifiable {
    var id = UUID()
    var type: String
    var frequency: AUValue
    var gain: AUValue
    var q: Float
}

class FileHandler: ObservableObject {
    @Published var currentTitle: String = "Unknown Title"
    @Published var currentArtist: String = "Unknown Artist"
    @Published var currentAlbum: String = "Unknown Album"
    @Published var currentArtworkImage: UIImage? = nil
    @Published var currentURL: URL?
    
    @Published var playbackProgress: Double = 0.0
    @Published var playbackDuration: Double = 0.0
    
    @Published var currentPlayQueue: [URL] = []
    @Published var currentPlayIndex: Int = 0
    @Published var cleanedFileNameMap: [String: URL] = [:]
    
    @Published var songsByArtist: [String: [String]] = [:]
    @Published var songsByAlbum: [String: [String]] = [:]
    
    @Published var albumsByArtist: [String] = []
    @Published var songsOfAlbum: [String] = []
    @Published var allSongs: [String] = []
    
    @Published var albumArtworks: [String: UIImage] = [:]
    
    @Published var currentTime: Float = 0.0
    @Published var duration: Float = 0.0
    
    @Published var files: [URL] = []
    
    private let fileManager = FileManager.default
    private let documentsURL: URL
    private let musicDirURL: URL
    
    private let audioExtensions = Set(["mp3", "flac", "wav", "m4a", "alac"])
    
    var player: AudioPlayer?
    var engine = AudioEngine()
    
    
    init() {
        documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        musicDirURL = documentsURL.appendingPathComponent("SPEQ_Music")
        initMusicDir()
        loadFiles()
    }
    
    func initMusicDir() {
        if fileManager.fileExists(atPath: musicDirURL.path) {
            print("Music directory found at \(musicDirURL.path())")
        } else {
            print("File does not exist, creating directory")
            do {
                try fileManager.createDirectory(at: musicDirURL, withIntermediateDirectories: true, attributes: nil)
                print("Directory created at \(musicDirURL.path)")
            } catch {
                print("Error creating directory: \(error.localizedDescription)")
            }
        }
    }
    
    func loadFiles() {
        do {
            var audioFiles: [URL] = []
            var fileMap: [String: URL] = [:]
            
            func collectAudioFiles(from directory: URL) {
                do {
                    let contents = try fileManager.contentsOfDirectory(
                        at: directory,
                        includingPropertiesForKeys: [.isDirectoryKey],
                        options: [.skipsHiddenFiles]
                    )
                    for item in contents {
                        let resourceValues = try item.resourceValues(forKeys: [.isDirectoryKey])
                        if resourceValues.isDirectory == true {
                            collectAudioFiles(from: item)
                        } else if audioExtensions.contains(item.pathExtension.lowercased()) {
                            let fileName = item.deletingPathExtension().lastPathComponent
                            let regex = try! NSRegularExpression(pattern: "^\\d+\\.\\s*")
                            let cleanFileName = regex.stringByReplacingMatches(
                                in: fileName,
                                options: [],
                                range: NSRange(location: 0, length: fileName.utf16.count),
                                withTemplate: ""
                            )
                            fileMap[cleanFileName] = item
                            audioFiles.append(item)
                        }
                    }
                } catch {
                    print("Error reading contents of \(directory.path): \(error.localizedDescription)")
                }
            }
            
            collectAudioFiles(from: musicDirURL)
            files = audioFiles
            cleanedFileNameMap = fileMap
        }
    }
    
    func loadCurrentSongMetadata(from url: URL) async {
        var songTitle = "Unknown Song"
        var albumName = "Unknown Album"
        var artistName = "Unknown Artist"
        var artworkImage: UIImage? = nil
        
        do {
            let asset = AVAsset(url: url)
            let metadata = try await asset.load(.commonMetadata)
            
            for item in metadata {
                if item.commonKey == .commonKeyTitle, let title = try await item.load(.stringValue) {
                    songTitle = title
                }
                if item.commonKey == .commonKeyArtist, let artist = try await item.load(.stringValue) {
                    artistName = artist
                }
                if item.commonKey == .commonKeyAlbumName, let album = try await item.load(.stringValue) {
                    albumName = album
                }
                if item.commonKey == .commonKeyArtwork, let artworkData = try await item.load(.dataValue) {
                    artworkImage = UIImage(data: artworkData)
                }
            }
        } catch {
            print("Error: Could not load metadata")
        }
        
        let tempTitle = songTitle
        let tempAlbum = albumName
        let tempArtist = artistName
        let tempArtwork = artworkImage
        
        DispatchQueue.main.async {
            self.currentTitle = tempTitle
            self.currentAlbum = tempAlbum
            self.currentArtist = tempArtist
            self.currentArtworkImage = tempArtwork
        }
    }
    
    func getFileURL(fileName: String) -> URL? {
        return musicDirURL.appendingPathComponent(fileName)
    }
    
    func organizeAllSongs() async {
        let queue = DispatchQueue(label: "com.filehandler.albumList")
        var songList: [String] = []
        
        for file in files {
            let songTitle = file.deletingPathExtension().lastPathComponent
                
                
            queue.sync {
                if !songList.contains(songTitle){
                    songList.append(songTitle)
                }
            }
        }
        
        let finalizedSongList = songList
        
        DispatchQueue.main.async {
            self.allSongs = finalizedSongList
        }
    }
    
    func organizeSongsOfAlbum(selectedAlbum: String) async {
        let queue = DispatchQueue(label: "com.filehandler.albumList")
        var songList: [String] = []
        var albumArtwork: UIImage? = nil
        
        for file in files {
            do {
                let asset = AVAsset(url: file)
                let metadata = try await asset.load(.commonMetadata)
                var albumName = "Unknown Album"
                var artistName = "Unknown Artist"
                let songTitle = file.deletingPathExtension().lastPathComponent
                var artworkImage: UIImage? = nil
                
                for item in metadata {
                    if item.commonKey == .commonKeyAlbumName, let album = try await item.load(.stringValue) {
                        albumName = album
                    }
                    if item.commonKey == .commonKeyArtist, let artist = try await item.load(.stringValue) {
                        artistName = artist
                    }
                    if item.commonKey == .commonKeyArtwork, let artworkData = try await item.load(.dataValue) {
                        artworkImage = UIImage(data: artworkData)
                    }
                }
                
                
                queue.sync {
                    if albumName == selectedAlbum{
                        if !songList.contains(songTitle){
                            songList.append(songTitle)
                            currentArtist = artistName
                        }
                        if let artworkImage = artworkImage {
                            albumArtwork = artworkImage
                        }
                    }
                }
            } catch {
                print("Error loading metadata for file: \(file.lastPathComponent)")
            }
        }
        
        let finalizedSongList = songList
        let finalizedAlbumArtwork = albumArtwork
        
        DispatchQueue.main.async {
            self.songsOfAlbum = finalizedSongList
            self.songsOfAlbum.sort()
            self.currentArtworkImage = finalizedAlbumArtwork
        }
    }
    
    func organizeAlbumsByArtist(selectedArtist: String) async {
        let queue = DispatchQueue(label: "com.filehandler.albumList")
        var albumList: [String] = []
        var albumArtworkDict: [String: UIImage] = [:]
        
        for file in files {
            do {
                let asset = AVAsset(url: file)
                let metadata = try await asset.load(.commonMetadata)
                var albumName = "Unknown Album"
                var artistName = "Unknown Artist"
                var artworkImage: UIImage? = nil
                
                for item in metadata {
                    if item.commonKey == .commonKeyAlbumName, let album = try await item.load(.stringValue) {
                        albumName = album
                    }
                    if item.commonKey == .commonKeyArtist, let artist = try await item.load(.stringValue) {
                        artistName = artist
                    }
                    if item.commonKey == .commonKeyArtwork, let artworkData = try await item.load(.dataValue) {
                        artworkImage = UIImage(data: artworkData)
                    }
                }
                
                
                queue.sync {
                    if artistName == selectedArtist{
                        if !albumList.contains(albumName){
                            albumList.append(albumName)
                        }
                        if let artworkImage = artworkImage {
                            albumArtworkDict[albumName] = artworkImage
                        }
                    }
                }
            } catch {
                print("Error loading metadata for file: \(file.lastPathComponent)")
            }
        }
        
        let finalizedAlbumList = albumList
        let finalizedAlbumArtworkDict = albumArtworkDict
        
        DispatchQueue.main.async {
            self.albumsByArtist = finalizedAlbumList
            self.albumArtworks = finalizedAlbumArtworkDict
        }
    }
    
    func organizeSongsByArtist() async {
        let queue = DispatchQueue(label: "com.filehandler.artistdict")
        var artistDict: [String: [String]] = [:]
        
        for file in files {
            do {
                let asset = AVAsset(url: file)
                let metadata = try await asset.load(.commonMetadata)
                var artistName = "Unknown Artist"
                var songTitle = file.deletingPathExtension().lastPathComponent
                
                for item in metadata {
                    if item.commonKey == .commonKeyTitle, let title = try await item.load(.stringValue) {
                        songTitle = title
                    }
                    if item.commonKey == .commonKeyArtist, let artist = try await item.load(.stringValue) {
                        artistName = artist
                    }
                }
                
                queue.sync {
                    if artistDict[artistName] == nil {
                        artistDict[artistName] = []
                    }
                    artistDict[artistName]?.append(songTitle)
                }
            } catch {
                print("Error loading metadata for file: \(file.lastPathComponent)")
            }
        }
        
        let finalizedArtistDict = artistDict
        
        DispatchQueue.main.async {
            self.songsByArtist = finalizedArtistDict
        }
    }
    
    func organizeSongsByAlbum(selectedAlbum: String?) async {
        let queue = DispatchQueue(label: "com.filehandler.albumdict")
        var albumDict: [String: [String]] = [:]
        var albumArtworkDict: [String: UIImage] = [:]
        
        let filesInOrder: [URL] = files.sorted { (url1, url2) -> Bool in
            let fileName1 = url1.deletingPathExtension().lastPathComponent
            let fileName2 = url2.deletingPathExtension().lastPathComponent
            
            let prefix1 = extractNumericPrefix(from: fileName1)
            let prefix2 = extractNumericPrefix(from: fileName2)
            
            return prefix1 < prefix2
        }

        for file in filesInOrder {
            do {
                let asset = AVAsset(url: file)
                let metadata = try await asset.load(.commonMetadata)
                var albumName = "Unknown Album"
                var songTitle = file.deletingPathExtension().lastPathComponent
                var artworkImage: UIImage? = nil

                for item in metadata {
                    if item.commonKey == .commonKeyTitle, let title = try await item.load(.stringValue) {
                        songTitle = title
                    }
                    if item.commonKey == .commonKeyAlbumName, let album = try await item.load(.stringValue) {
                        albumName = album
                    }
                    if item.commonKey == .commonKeyArtwork, let artworkData = try await item.load(.dataValue) {
                        artworkImage = UIImage(data: artworkData)
                    }
                }

                queue.sync {
                    if selectedAlbum == nil {
                        if albumDict[albumName] == nil {
                            albumDict[albumName] = []
                        }
                        albumDict[albumName]?.append(songTitle)

                        if let artworkImage = artworkImage {
                            albumArtworkDict[albumName] = artworkImage
                        }
                    } else {
                        if albumName == selectedAlbum {
                            if albumDict[albumName] == nil {
                                albumDict[albumName] = []
                            }
                            albumDict[albumName]?.append(songTitle)

                            if let artworkImage = artworkImage {
                                albumArtworkDict[albumName] = artworkImage
                            }
                        }
                    }
                }
            } catch {
                print("Error loading metadata for file: \(file.lastPathComponent)")
            }
        }

        let finalizedAlbumDict = albumDict
        let finalizedAlbumArtworkDict = albumArtworkDict

        DispatchQueue.main.async {
            self.songsByAlbum = finalizedAlbumDict
            self.albumArtworks = finalizedAlbumArtworkDict
        }
    }

    func extractNumericPrefix(from fileName: String) -> Int {
        let components = fileName.split(separator: " ")
        if let firstComponent = components.first, let number = Int(firstComponent.prefix(while: { $0.isNumber })) {
            return number
        }
        return Int.max
    }

    func addSongsToPlayQueue(songToAdd: URL) async {
        currentPlayQueue.append(songToAdd)
    }
    
    func createPlayQueue(firstSong: URL) async {
        DispatchQueue.main.async {
            self.currentPlayQueue.removeAll()
            self.currentPlayIndex = 0
        }
        
        if let albumSongs = songsByAlbum[currentAlbum] {
            print("Songs in album:")
            albumSongs.forEach { print($0) }

            var firstSongName = firstSong.deletingPathExtension().lastPathComponent

            let regex = try! NSRegularExpression(pattern: "^\\d+\\.\\s*")
            let range = NSRange(location: 0, length: firstSongName.utf16.count)
            firstSongName = regex.stringByReplacingMatches(in: firstSongName, options: [], range: range, withTemplate: "")

            print("First song name (without index): \(firstSongName)")

            firstSongName = firstSongName.trimmingCharacters(in: .whitespaces)

            if let startIndex = albumSongs.firstIndex(where: { $0.trimmingCharacters(in: .whitespaces) == firstSongName }) {
                for i in startIndex..<albumSongs.count {
                    let songTitle = albumSongs[i].trimmingCharacters(in: .whitespaces)

                    if let songURL = files.first(where: { file in
                        let fileName = file.deletingPathExtension().lastPathComponent
                        let cleanFileName = regex.stringByReplacingMatches(in: fileName, options: [], range: NSRange(location: 0, length: fileName.utf16.count), withTemplate: "")
                        return cleanFileName.trimmingCharacters(in: .whitespaces) == songTitle
                    }) {
                        DispatchQueue.main.async {
                            self.currentPlayQueue.append(songURL)
                        }
                    }
                }
                print("Play queue size: \(currentPlayQueue.count)")
            } else {
                print("Error: First song not found in album.")
            }
        }
    }

    func playNext() async {
        guard !currentPlayQueue.isEmpty else {
            print("Play queue empty")
            return
        }
        let nextIndex = currentPlayIndex + 1
        if nextIndex < currentPlayQueue.count {
            await MainActor.run {
                self.currentPlayIndex = nextIndex
                print("current idx after update: \(self.currentPlayIndex)")
            }
            
            print("next idx: \(nextIndex)")
            print("current idx: \(currentPlayIndex)")
            let nextSong = currentPlayQueue[nextIndex]
            await loadCurrentSongMetadata(from: nextSong)
            await togglePlayback(from: nextSong, keepPlaying: true)
        } else {
            print("Reached the end of the play queue.")
        }
    }

    func playPrevious() async -> Bool{
        guard !currentPlayQueue.isEmpty else {
            print("Play queue empty")
            return false
        }
        let previousIndex = currentPlayIndex - 1
        if previousIndex >= 0 {
            await MainActor.run {
                self.currentPlayIndex = previousIndex
                print("current idx after update: \(self.currentPlayIndex)")
            }
            
            let previousSong = currentPlayQueue[currentPlayIndex]
            await loadCurrentSongMetadata(from: previousSong)
            await togglePlayback(from: previousSong, keepPlaying: true)
        } else {
            print("Reached the start of the play queue.")
            let currentSong = currentPlayQueue[currentPlayIndex]
            await loadCurrentSongMetadata(from: currentSong)
            await togglePlayback(from: currentSong, keepPlaying: true, restart: true)
            return true
        }
        return false
    }


    func togglePlayback(from url: URL, keepPlaying: Bool, restart: Bool = false) async {
        if player != nil {
            if currentURL == url {
                if keepPlaying {
                    print("keep playing true")
                    if restart {
                        player?.stop()
                        engine.stop()
                        setupPlayer(with: url)
                        player?.play()
                    }
                    return
                }
                
                if player?.status == .playing {
                    print("Pausing")
                    player?.pause()
                } else {
                    print("resuming")
                    player?.resume()
                }
            } else {
                print("different song, stopping player")
                player?.stop()
                engine.stop()
                setupPlayer(with: url)
                player?.play()
                DispatchQueue.main.async {
                    self.currentURL = url
                }
                print("different song, started player")
            }
        } else {
            print("No player exists")
            setupPlayer(with: url)
            player?.play()
            DispatchQueue.main.async {
                self.currentURL = url
            }
        }
    }

    func setupPlayer(with url: URL) {
        do {
            player = AudioPlayer(url: url)
            DispatchQueue.main.async {
                self.currentURL = url
            }
            
            let eqFilters = loadEQFilters()
            var maxGain: AUValue = 1.0

            func dbToLinear(gainDB: AUValue) -> AUValue {
                return pow(10, gainDB / 20)
            }

            let gainScalingFactor: AUValue = 2.0

            var currentNode: Node = player!
            for filter in eqFilters {
                let gainInDB = max(min(filter.gain, 30), -30)
                
                let scaledGainInDB = gainInDB * gainScalingFactor
                let linearGain = dbToLinear(gainDB: scaledGainInDB)
                
                if linearGain > maxGain {
                    maxGain = linearGain
                }

                switch filter.type {
                case "peak":
                    if filter.q == 0 {
                        print("Q-value cannot be 0")
                        continue
                    }
                    let peakFilter = PeakingParametricEqualizerFilter(
                        currentNode,
                        centerFrequency: filter.frequency,
                        gain: linearGain,
                        q: filter.q
                    )
                    currentNode = peakFilter
                    print("FILTER GAIN: \(scaledGainInDB) dB (scaled), Linear Gain: \(linearGain)")

                case "low-shelf":
                    if filter.q == 0 {
                        print("Q-value cannot be 0")
                        continue
                    }
                    let lowShelfFilter = LowShelfParametricEqualizerFilter(
                        currentNode,
                        cornerFrequency: filter.frequency,
                        gain: linearGain,
                        q: filter.q
                    )
                    currentNode = lowShelfFilter
                    print("FILTER GAIN: \(scaledGainInDB) dB (scaled), Linear Gain: \(linearGain)")

                case "high-shelf":
                    if filter.q == 0 {
                        print("Q-value cannot be 0")
                        continue
                    }
                    let highShelfFilter = HighShelfParametricEqualizerFilter(
                        currentNode,
                        centerFrequency: filter.frequency,
                        gain: linearGain,
                        q: filter.q
                    )
                    currentNode = highShelfFilter
                    print("FILTER GAIN: \(scaledGainInDB) dB (scaled), Linear Gain: \(linearGain)")

                default:
                    print("Unknown filter type: \(filter.type)")
                }
            }

            engine.output = currentNode
            
            let preampGain = 1 / maxGain
            print("Preamp Gain: \(preampGain)")
            
            if preampGain < 1 {
                engine.mainMixerNode?.volume = preampGain
            } else {
                engine.mainMixerNode?.volume = 1
            }

            try engine.start()

        } catch {
            print("Error setting up player: \(error)")
        }
    }


    func loadEQFilters() -> [EQFilter] {
        let fileURL = documentsURL.appendingPathComponent("eq_profile.json")
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([EQFilter].self, from: data)
        } catch {
            print("Error loading EQ filters: \(error)")
            return []
        }
    }
}
