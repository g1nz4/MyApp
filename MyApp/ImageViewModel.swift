import Foundation

struct Image {
    let url: URL
    var name: String { url.lastPathComponent }
}

final class ImageViewModel {

    private let storage: ImageStorageProtocol

    private(set) var images: [Image] = []

    var onLoadData: (([Image]) -> Void)?
    var onInsertItem: ((Int) -> Void)?
    var onDeleteItem: ((Int) -> Void)?
    var onError: ((String) -> Void)?

    init(storage: ImageStorageProtocol) {
        self.storage = storage
    }

    func load() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                let urls = try self.storage.loadImages()
                let loadedImages = urls.map { Image(url: $0) }

                DispatchQueue.main.async {
                    self.images = loadedImages
                    self.onLoadData?(loadedImages)
                }
            } catch {
                DispatchQueue.main.async {
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }

    func add(imageData: Data) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                let url = try self.storage.addImage(imageData: imageData)
                let newImage = Image(url: url)

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

    func delete(at index: Int) {
        guard images.indices.contains(index) else { return }
        let image = images[index]

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                try self.storage.deleteImage(at: image.url)

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
}
