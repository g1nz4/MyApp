import Foundation

protocol ImageStorageProtocol {
    var rootDirectory: URL { get }
    
    func loadImages(in directory: URL) throws -> [URL]
    func addImage(imageData: Data, name: String?, in directory: URL) throws -> URL
    func deleteImage(at url: URL) throws
    func addFolder(name: String, in directory: URL) throws -> URL
}

final class ImageStorage: ImageStorageProtocol {
   
    let rootDirectory: URL
    
    init(directory: URL) {
        self.rootDirectory = directory
        
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
    
    func loadImages(in directory: URL) throws -> [URL] {
        let urls = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        
        return urls.filter {
            ["png", "jpg", "jpeg"].contains($0.pathExtension.lowercased())
        }
    }
    
    func addImage(imageData: Data, name: String?, in directory: URL) throws -> URL {
        let id = UUID().uuidString
        var baseName: String
        
        if let name = name, !name.isEmpty {
            baseName = (name as NSString).deletingPathExtension
        } else {
            baseName = "image_\(id)"
        }
        
        baseName = baseName.replacingOccurrences(of: " ", with: "_")
        
        let fileName = "\(baseName).jpg"
        let url = directory.appendingPathComponent(fileName)
        try imageData.write(to: url)
        
        return url
    }
    
    func deleteImage(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
    
    func addFolder(name: String, in directory: URL) throws -> URL {
        let n = name.replacingOccurrences(of: "/", with: "_")
        let folderURL = directory.appendingPathComponent(n, isDirectory: true)

        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        
        return folderURL
    }
}
