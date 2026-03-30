import Foundation

protocol ImageStorageProtocol {
    func loadImages() throws -> [URL]
    func addImage(imageData: Data) throws -> URL
    func deleteImage(at url: URL) throws
}

final class ImageStorage: ImageStorageProtocol {
   
    private let directory: URL
    
    init(directory: URL) {
        self.directory = directory
    }
    
    func loadImages() throws -> [URL] {
        let urls = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        
        return urls.filter {
            ["png", "jpg", "jpeg"].contains($0.pathExtension.lowercased())
        }
    }
    
    func addImage(imageData: Data) throws -> URL {
        let imageName = "image_\(UUID().uuidString).jpg"
        let url = directory.appendingPathComponent(imageName)
        try imageData.write(to: url)
        
        return url
    }
    
    func deleteImage(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
}
