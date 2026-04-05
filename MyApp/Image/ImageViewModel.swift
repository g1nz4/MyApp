import Foundation

struct Image {
    let url: URL
    var userTitle: String
    var name: String { url.lastPathComponent }
    var date: Date
    var size: Double
    
    init(url: URL, userTitle: String? = nil) {
        self.url = url
        
        let values = try? url.resourceValues(forKeys: [.creationDateKey, .fileSizeKey])
        self.date = values?.creationDate ?? Date()
        self.size = Double(values?.fileSize ?? 0)
        self.userTitle = userTitle ?? url.lastPathComponent
    }
}

struct Folder {
    let url: URL
    var name: String { url.lastPathComponent }
}

final class ImageViewModel {

    private let storage: ImageStorageProtocol

    private(set) var images: [Image] = []
    private(set) var folders: [Folder] = []
    private(set) var currentDirectory: URL

    var onLoadData: ((_ folders: [Folder], _ images: [Image]) -> Void)?
    var onInsertItem: ((Int) -> Void)?
    var onDeleteItem: ((Int) -> Void)?
    var onDeleteFolder: ((Int) -> Void)?
    var onError: ((String) -> Void)?
    var instanceStorage: ImageStorageProtocol { storage }

    init(storage: ImageStorageProtocol, directory: URL? = nil) {
        self.storage = storage
        self.currentDirectory = directory ?? storage.rootDirectory
    }
    
    private func sort<T>(_ items: [T], by name: (T) -> String) -> [T] {
        let ascending = SettingsStorage.shared.sort
        return items.sorted {
            let l = name($0).lowercased()
            let r = name($1).lowercased()
            return ascending ? (l < r) : (l > r)
        }
    }
    
    func changeDirectory(_ directory: URL) {
        currentDirectory = directory
        load()
    }

    func load() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                let urls = try FileManager.default.contentsOfDirectory(
                    at: self.currentDirectory,
                    includingPropertiesForKeys: [.isDirectoryKey],
                    options: [.skipsHiddenFiles]
                )
                var folders: [Folder] = []
                var imageURLs: [URL] = []
                
                for url in urls {
                    let values = try url.resourceValues(forKeys: [.isDirectoryKey])
                    
                    if values.isDirectory == true {
                        folders.append(Folder(url: url))
                    } else if ["png", "jpg", "jpeg"].contains(url.pathExtension.lowercased()) {
                        imageURLs.append(url)
                    }
                }
                
                let loadedImages = imageURLs.map { Image(url: $0) }
                let sortedFolders = self.sort(folders) { $0.name }
                let sortedImages = self.sort(loadedImages) {$0.userTitle}

                DispatchQueue.main.async {
                    self.folders = sortedFolders
                    self.images = sortedImages
                    self.onLoadData?(sortedFolders, sortedImages)
                }
            } catch {
                DispatchQueue.main.async {
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }

    func add(imageData: Data, name: String?) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                let url = try self.storage.addImage(
                    imageData: imageData,
                    name: name,
                    in: self.currentDirectory
                )
                let newImage = Image(url: url, userTitle: name)

                DispatchQueue.main.async {
                    let newIndex = self.images.count
                    self.images.append(newImage)
                    self.onInsertItem?(newIndex)
                }
            } catch {
                DispatchQueue.main.async {
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }

    func deleteImage(at index: Int) {
        guard images.indices.contains(index) else { return }
        let image = images[index]

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                try self.storage.deleteItem(at: image.url)

                DispatchQueue.main.async {
                    self.images.remove(at: index)
                    self.onDeleteItem?(index)
                }
            } catch {
                DispatchQueue.main.async {
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func addFolder(name: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                let url = try self.storage.addFolder(
                    name: name,
                    in: self.currentDirectory
                )
                let folder = Folder(url: url)

                DispatchQueue.main.async {
                    self.folders.append(folder)
                    self.onLoadData?(self.folders, self.images)
                }
            } catch {
                DispatchQueue.main.async {
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func deleteFolder(at index: Int) {
        guard folders.indices.contains(index) else { return }
        let folder = folders[index]

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                try storage.deleteItem(at: folder.url)

                DispatchQueue.main.async {
                    self.folders.remove(at: index)
                    self.onDeleteFolder?(index)
                }
            } catch {
                DispatchQueue.main.async {
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
}
