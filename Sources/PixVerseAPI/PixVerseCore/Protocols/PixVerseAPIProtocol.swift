//
//  File.swift
//  PixVerseAPI
//
//  Created by катенька on 14.07.2025.
//

import Foundation
import RxSwift
import Alamofire

public protocol PixVerseAPIProtocol {
    func fetchTokensCount(userId: String, appId: String) -> Observable<TokensBalanceResponse>
    func fetchTemplates(appBundle: String) -> Observable<TemplateListResponce>
    func fetchPhotoTemplates(appBundle: String) -> RxSwift.Observable<PhotoTemplateListResponce>
    func generatePhoto(from prompt: String, userID: String, appBundle: String) -> Observable<PhotoResult>
    func generatePhoto(from prompt: String, usingImage data: Data, imageName: String, userID: String, appBundle: String) -> Observable<PhotoResult>
    func generatePhoto(byTemplateID id: String, usingImage data: Data, imageName: String, userID: String, appBundle: String) -> Observable<PhotoResult>
    func generateVideo(from prompt: String, userID: String, appBundle: String) -> Observable<VideoGenerationTask>
    func generateVideo(from prompt: String, usingImage data: Data, imageName: String, userID: String, appBundle: String) -> Observable<VideoGenerationTask>
    func generateVideo(byTemplateID id: String, usingImage data: Data, imageName: String, userID: String, appBundle: String) -> Observable<VideoGenerationTask>
    func generateVideo(usingVideo fileURL: URL, videoName: String, byStyleID id: String, userID: String, appBundle: String) -> Observable<VideoGenerationTask>
    func checkStatus(requestID: String) -> Observable<VideoResult>
    func handleVideoGenerationStatus(videoID: String) -> Observable<(String, VideoResult)>
}
