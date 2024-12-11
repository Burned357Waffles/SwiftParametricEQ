<h1>Swift Parametric Equalizer (SPEQ)</h1>
<h2>Brandon Watanabe</h2>
<h2>CSC 780-01 Term Project</h2>
<hr>

<h3>About</h3>
Welcome to Swift Parametric Equalizer. This app was developed by Brandon Watanabe for CSC 780-01. With this app you can play your favorite downloaded songs and adjust a parametric equalizer to suit your headphones. If you do not know what EQ filters to use, consider using the AutoEQ feature at https://graph.hangout.audio/ to find good settings for your specific headphone or IEM.

<hr>

<h3>Installation Guide</h3>
Clone this repository and open the project in Xcode. 

Note: This project was entirely tested on an iPhone 15 Pro Max Simulator in portrait mode.

<hr>

<h3>Setting Up Your Music Directory</h3>

The music folder should be found in the Files App named "SPEQ_Music"

This is where you will add your folders with your music. Please follow the following format:
SPEQ_Music/AlbumName/song.mp3

Example path for my simulator:
/Users/Xcode/Library/Developer/CoreSimulator/Devices/F00BCDBA-B55E-4D29-A141-2D00D0544339/data/Containers/Data/Application/8E7C5B16-C271-4C59-9177-E3AAB10FC31E/Documents/SPEQ_Music/

If you run this in Xcode the path will be printed out so you can find it.

In the documents folder of the app, there will be a json named "eq_profile.json" which will store the values of all your EQ filters. If it is not already there, it can be created in the app. A sample eq profile is included in this repo, please place it in the correct directory.

The files app should look like the following photo:

<img src="https://github.com/user-attachments/assets/ff571738-e189-4c52-9bda-ba46faecfa7d" width=200>

<hr>

<h3>Features</h3>

This app is a fully functioning music player which can read mp3, flac, wav, m4a, and alac files that are downloaded locally on your device. We use the metadata stored in the song files to determine song title, album title, artist name, and album artwork. If one of these is not found it will be given a default value or image. 

You can view all artists, all albums, all songs, all albums by a specific artist, and all songs in a specific album. 

<img src=https://github.com/user-attachments/assets/85bfa1d3-8c12-4ee5-8a30-5e75da957e85 width=200>
<img src=https://github.com/user-attachments/assets/66e845e0-b05c-46a8-9e8f-604b37200e9e width=200>
<img src=https://github.com/user-attachments/assets/5fc449fb-6923-4fc9-9c1e-eb85611b65ed width=200>
<img src=https://github.com/user-attachments/assets/a64de97d-b321-4766-8c70-4db9434930a0 width=200>
<img src=https://github.com/user-attachments/assets/b403f8d7-7e7b-490e-8e4e-4e71deb7212d width=200>
<img src=https://github.com/user-attachments/assets/56922244-8bc5-4756-addf-a322e5ec08f5 width=200>


When you click a song, a play queue will be created with the remaining songs in the album. For example, if there are 6 songs in an album and you select the third song, the play queue would be [song 3, song 4, song 5, song 6]. If you rewind to the beginning of the queue, it will restart the song.

The PlayerView contains a few playback controls: play/pause, previous track, and next track. It will show the song title, album title, artist name, and album artwork of the currently playing song. From this view you can also access the Equalizer view. 

<img src=https://github.com/user-attachments/assets/dc21f52c-167b-4e0e-add7-bfceeac97c5d width=200>

The Equalizer view allows you to create a list of Equalizer Filters. You can add as many filters as you like by pressing the add button and remove then by swipinig left on the filter. There are 3 options for the filter type peak, low-shelf, and high-shelf which are accessible through a dropdown. Each filter requires a Filter Type, Frequency, Q-Factor, and Gain. The filters are sorted by frequency. The preamp gain is automatically calculated to avoid clipping. When you hit save, these filters will be written to a json file in the app's documents directory. Adding a new filter will have the default values: Filter Type: Peak, Frequency: 1000 Hz, Q-Factor: 1.41, Gain: 0.

The song MUST be restarted or a new song must be selected to apply the changes. These will be persistent, so if you close and open the app the EQ profile you created will still be loaded.

<img src=https://github.com/user-attachments/assets/4d1b1821-3f4b-46a7-8e0a-c07c95519d4a width=200>

There is also an Information view which has a short description of the app.

<hr>

<h3>Technical Info</h3>
This project uses SwiftUI, FileManager, and the following packages:

- AudioKit
  
- SoundpipeAudioKit

- AVFoundation

- Foundation


The project has the following views:
- MainMenuView

- ArtistView

- AlbumView

- SongView

- InformationView

- PlayerView

- EQView

The FileHandler class takes care of reading the song files, organizing the song files by artist, album, etc, creating and applying the EQ filters, and playing the music files.

<hr>

<h3>Acknowledgments</h3>
ChatGPT was used to aid in some of the code for this project.

AudioKit: https://github.com/AudioKit/AudioKit/

SoundpipeAudioKit: https://github.com/AudioKit/SoundpipeAudioKit/

FileManager Tutorial: https://medium.com/@shashidj206/mastering-filemanager-in-swift-and-swiftui-7f29d6247644

