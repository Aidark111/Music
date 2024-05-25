import Foundation
import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

/// ImportFileManager позволяет выбирать аудиофайлы и импортировать их в приложение
struct ImportFileManager: UIViewControllerRepresentable {
    
    @Binding var songs: [SongModel]
    
    /// Координатор управляет задачами между SwiftUI и UIKit
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    /// Метод который создает и настраивает UIDocumentPickerViewController, который используется для выбора аудиофайлов.
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        /// Разрешение открытия файлов с типом "public.audio" (MP3, WAV) Другие форматы: "public.image" (JPEG, PNG, TIF) / "public.video" / "com.adobe.pdf"
      let documentTypes = [UTType.audio]
      // Initialize UIDocumentPickerViewController with forOpeningContentTypes
      let picker = UIDocumentPickerViewController(forOpeningContentTypes: documentTypes, asCopy: true)
        /// Разрешение выбрать только один файл
        picker.allowsMultipleSelection = false
        /// Показ разшерения файлов
        picker.shouldShowFileExtensions = true
        /// Установка координатора в качестве делегата
        picker.delegate = context.coordinator
        return picker
    }
    
    /// Метод предназначен для обновления контроллера с новыми данными. В данном случае он пуст, так как все необходимые настройки выполнены при создании
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    /// Координатор служит связующим звеном между UIDocumentPicker и ImportFileManager
    class Coordinator: NSObject, UIDocumentPickerDelegate  {
        
        /// Ссылка на родительский компонент ImportFileManager, чтобы можно было с ним взаимодействовать
        var parent: ImportFileManager
        
        init(parent: ImportFileManager) {
            self.parent = parent
        }
        
        /// Метод вызывается когда пользователь выбирает песню
        /// Метод обрабатывает выбраный URL и создает песню типом SongModel и после добавлет песлю в массив songs
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            
            /// guard let, безопастно извлекает первый элемент из массива urls. Если массив пуст, то urls.first вернет nil и условие не пропустит что приведет к выходу из метода documentPicker
            /// После извлечения url, метод startAccessingSecurityScopedResource вызывается для начала доступа к защищеному ресурсу
            guard let url = urls.first, url.startAccessingSecurityScopedResource() else { return }
            
            /// Гарантирует что метод stopAccessingSecurityScopedResource будет вызван когда выполнение documentPicker завершится, независимо от того успешно или нет и ресурс безопастности будет закрыт и корректно освобожден из памяти
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                
                /// Получение данных файла
                let document = try Data(contentsOf: url)
                
                /// Создание AVAsset для извлечения метаданных
                let asset = AVAsset(url: url)
                
                /// Инициализируем объект SongModel
                var song = SongModel(name: url.lastPathComponent, data: document)
                
                /// Цикл для итерации по метаданным аудиофайла чтобы извлечь (исполнитель, обложка, название)
                let metadata = asset.metadata
                for item in metadata {
                    
                    /// Проверяет есть ли метаданные у файла через ключ / значение
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
                
                /// Получения продолжительности песни
                song.duration = CMTimeGetSeconds(asset.duration)
                
                /// Добавление песни в массив songs если там такое еще нет
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
