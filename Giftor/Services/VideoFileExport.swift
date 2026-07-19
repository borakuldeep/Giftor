//
//  VideoFileExport.swift
//  Giftor
//
//  Created by Kuldeep Bora on 31.01.26.
//
import AVFoundation
import SwiftUI
import UniformTypeIdentifiers

struct VideoFileExport: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            // This copies the file to a secure, temporary location for your app
            SentTransferredFile(movie.url)
        } importing: { received in
            // Create a unique destination in your temp directory
            let fileName = "\(UUID().uuidString).mov"
            let copy = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            if FileManager.default.fileExists(atPath: copy.path) {
                try FileManager.default.removeItem(at: copy)
            }
            
            try FileManager.default.copyItem(at: received.file, to: copy)
            return VideoFileExport(url: copy)
        }
    }
}



func exportCompressedVideo(
    asset: AVAsset,
    outputURL: URL
) async throws {

    guard let exportSession = AVAssetExportSession(
        asset: asset,
        presetName: AVAssetExportPreset640x480
    ) else {
        throw VideoError.exportFailed
    }

    //exportSession.outputURL = outputURL
    //exportSession.outputFileType = .mp4
    exportSession.shouldOptimizeForNetworkUse = true
    

    try await exportSession.export(to: outputURL, as: .mp4)

//    if exportSession.status != .completed {
//        throw exportSession.error ?? VideoError.exportFailed
//    }
}
