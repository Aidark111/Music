import Foundation
import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

// ImportFileManager позволяет выбирать аудиофайлы и импортировать их в приложение
struct ImportFileManager: UIViewControllerRepresentable {
    
    @Binding var songs: [SongModel]
    
    // координатор управляет задачами между SwiftUI и UIKit
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // этот метод создает и настраивает UIDocumentPickerViewController, который используется для выбора аудиофайлов.
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // разрешение открытия файлов с типами мп3 wav
      let documentTypes = [UTType.audio]
      // initialize UIDocumentPickerViewController with forOpeningContentTypes
      let picker = UIDocumentPickerViewController(forOpeningContentTypes: documentTypes, asCopy: true)
        // разрешение выбрать только один файл
        picker.allowsMultipleSelection = false
        // показ разшерения файлов
        picker.shouldShowFileExtensions = true
        //  установка координатора в качестве делегата
        picker.delegate = context.coordinator
        return picker
    }
    
    // для обновления контроллера с новыми данными. в данном случае он пуст, так как все необходимые настройки выполнены при создании
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    // координатор служит связующим звеном между UIDocumentPicker и ImportFileManager
    class Coordinator: NSObject, UIDocumentPickerDelegate  {
        
        // ссылка на родительский компонент ImportFileManager, чтобы можно было с ним взаимодействовать
        var parent: ImportFileManager
        
        init(parent: ImportFileManager) {
            self.parent = parent
        }
        
        // вызывается когда пользователь выбирает песню
        // Метод обрабатывает выбраный URL и создает песню типом SongModel и после добавлет песлю в массив songs
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            
            /// guard let, безопастно извлекает первый элемент из массива urls. eсли массив пуст, то urls.first вернет nil и условие не пропустит что приведет к выходу из метода documentPicker
            //  после извлечения url, метод startAccessingSecurityScopedResource вызывается для начала доступа к защищеному ресурсу
            guard let url = urls.first, url.startAccessingSecurityScopedResource() else { return }
            
            // гарантирует что метод stopAccessingSecurityScopedResource будет вызван когда выполнение documentPicker завершится, независимо от того успешно или нет и ресурс безопастности будет закрыт и корректно освобожден из памяти
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                
                // получение данных файла
                let document = try Data(contentsOf: url)
                
                // создание AVAsset для извлечения метаданных
                let asset = AVAsset(url: url)
                
                // инициализируем объект SongModel
                var song = SongModel(name: url.lastPathComponent, data: document)
                
                // цикл для итерации по метаданным аудиофайла чтобы извлечь исполнитель, обложка, название
                let metadata = asset.metadata
                for item in metadata {
                    
                    // проверяет есть ли метаданные у файла через ключ / значение
                    guard let key = item.commonKey?.rawValue, let value = item.value else { continue }
                    switch key {
                    case AVMetadataKey.commonKeyArtist.rawValue:
                        song.artist = value as? String
                    case AVMetadataKey.commonKeyArtwork.rawValue:
                        song.coverImage = value as? Data
                    case AVMetadataKey.commonKeyTitle.rawValue:
                        song.name = value as? String ?? song.name
                    default:
                        break
                    }
                }
                
                // получения продолжительности песни
                song.duration = CMTimeGetSeconds(asset.duration)
                
                // добавление песни в массив songs если там такое еще нет
                if !self.parent.songs.contains(where: { $0.name == song.name }) {
                    DispatchQueue.main.async {
                        self.parent.songs.append(song)
                    }
                } else {
                    print("Song with the same name already exists")
                }
            } catch {
                print("Error processing the file: \(error)")
            }
        }
    }
}
