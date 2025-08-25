// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Alamofire
import RxSwift
import RxAlamofire

@available(iOS 16.0, *)
public final class PixVerseAPI: PixVerseAPIProtocol {
    nonisolated(unsafe) public static let shared = PixVerseAPI()
    
    private let session: Session
    let pixVerseURL = "https://trust.coreapis.space/pixverse"
    let chatGPTURL = "https://trust.coreapis.space/chatgpt"
    
    let defaultHeaders: HTTPHeaders = [.accept("application/json")]
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 120
        self.session = Session(configuration: configuration)
    }
    
    public func fetchTemplates(appBundle: String) -> Observable<TemplateListResponce> {
        let url = "\(pixVerseURL)/api/v1/get_templates/\(appBundle)"
        return session.request(url)
            .validate()
            .rx
            .responseDecodable()
            .map { $1 }
    }
    
    public func fetchPhotoTemplates(appBundle: String) -> Observable<PhotoTemplateListResponce> {
        let url = "\(chatGPTURL)/api/v1/get_templates/\(appBundle)"
        return session.request(url)
            .validate()
            .rx
            .responseDecodable()
            .map { $1 }
    }
    
    public func generatePhoto(from prompt: String, userID: String, appBundle: String) -> Observable<PhotoResult> {
        let url = "\(chatGPTURL)/api/v1/text2photo"
        
        let params = [
            "user_id": userID,
            "app_id": appBundle,
            "prompt": prompt
        ]
        let headers: HTTPHeaders = defaultHeaders
        
        return postRequest(to: url, parameters: params, headers: headers)
    }
    
    public func generatePhoto(from prompt: String, usingImage data: Data, imageName: String, userID: String, appBundle: String) -> Observable<PhotoResult> {
        let url = URL(string: "\(chatGPTURL)/api/v1/photo2photo")!.appending(queryItems: [
            URLQueryItem(name: "user_id", value: userID),
            URLQueryItem(name: "app_id", value: appBundle),
            URLQueryItem(name: "prompt", value: prompt)
        ])
        let headers: HTTPHeaders = defaultHeaders
        
        return uploadMultipart(to: url, imageData: data, imageName: imageName, headers: headers)
    }
    
    public func generatePhoto(byTemplateID id: String, usingImage data: Data, imageName: String, userID: String, appBundle: String) -> Observable<PhotoResult> {
        let url = URL(string: "\(chatGPTURL)/api/v1/template2photo")!.appending(queryItems: [
            URLQueryItem(name: "user_id", value: userID),
            URLQueryItem(name: "app_id", value: appBundle),
            URLQueryItem(name: "id", value: id)
        ])
        let headers: HTTPHeaders = defaultHeaders
        
        return uploadMultipart(to: url, imageData: data, imageName: imageName, headers: headers)
    }
    
    public func generateVideo(from prompt: String, userID: String, appBundle: String) -> Observable<VideoGenerationTask> {
        let url = "\(pixVerseURL)/api/v1/text2video"
        let params = [
            "userId": userID,
            "appId": appBundle,
            "promptText": prompt
        ]
        let headers: HTTPHeaders = defaultHeaders
        
        return postRequest(to: url, parameters: params, headers: headers)
    }
    
    public func generateVideo(from prompt: String, usingImage data: Data, imageName: String, userID: String, appBundle: String) -> Observable<VideoGenerationTask> {
        let url = URL(string: "\(pixVerseURL)/api/v1/image2video")!.appending(queryItems: [
            URLQueryItem(name: "userId", value: userID),
            URLQueryItem(name: "appId", value: appBundle),
            URLQueryItem(name: "promptText", value: prompt)
        ])
        let headers: HTTPHeaders = defaultHeaders
        
        return uploadMultipart(to: url, imageData: data, imageName: imageName, headers: headers)
    }
    
    public func generateVideo(byTemplateID id: String, usingImage data: Data, imageName: String, userID: String, appBundle: String) -> Observable<VideoGenerationTask> {
        let url = URL(string: "\(pixVerseURL)/api/v1/template2video")!.appending(queryItems: [
            URLQueryItem(name: "userId", value: userID),
            URLQueryItem(name: "appId", value: appBundle),
            URLQueryItem(name: "templateId", value: id)
        ])
        let headers: HTTPHeaders = defaultHeaders
        
        return uploadMultipart(to: url, imageData: data, imageName: imageName, headers: headers)
    }
    
    public func checkStatus(requestID: String) -> Observable<VideoResult> {
        var url = "\(pixVerseURL)/api/v1/status"
        let params = [
            "id": requestID
        ]
        let headers = defaultHeaders
        
        return AF.request(url, parameters: params, encoder: URLEncodedFormParameterEncoder(destination: .queryString))
            .validate()
            .rx
            .responseDecodable()
            .map { $1 }
    }
    
    public func handleVideoGenerationStatus(videoID: String) -> Observable<(String, VideoResult)> {
        return Observable<Int>.interval(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
            .flatMap { _ -> Observable<(String, VideoResult)> in
                self.checkStatus(requestID: videoID)
                    .map { (videoID, $0) }
            }
    }
    
    func postRequest<T: Decodable>(
        to url: String,
        parameters: [String: String],
        headers: HTTPHeaders
    ) -> Observable<T> {
        self.session.request(
            url,
            method: .post,
            parameters: parameters,
            encoder: URLEncodedFormParameterEncoder(destination: .queryString),
            headers: headers
        )
            .validate()
            .cURLDescription { print($0) }
            .rx
            .responseDecodable()
            .map { $1 }
    }
    
    func uploadMultipart<T: Decodable>(
        to url: URL,
        imageData: Data,
        imageName: String,
        headers: HTTPHeaders
    ) -> Observable<T> {
        RxAlamofire.upload(
            multipartFormData: { formData in
                formData.append(imageData, withName: "image", fileName: imageName, mimeType: "image/png")
            },
            to: url,
            method: .post,
            headers: headers
        )
        .flatMap { uploadRequest in
            uploadRequest
                .cURLDescription { print($0) }
                .validate()
                .rx
                .responseDecodable()
                .map { $1 }
        }
    }
}

@available(iOS 16.0, *)
public extension PixVerseAPI {
    enum GenerationType {
        case videoByPrompt(prompt: String)
        case videoByImagePrompt(imageData: Data, imageName: String, prompt: String)
        case videoByTemplate(imageData: Data, imageName: String, templateID: String)
        case photoByPrompt(prompt: String)
        case photoByImagePrompt(imageData: Data, imageName: String, prompt: String)
    }
}

public final class MockPixVerseAPI: PixVerseAPIProtocol {
    nonisolated(unsafe) public static let shared = MockPixVerseAPI()
    
    private var createdVideos: [Int: VideoResult] = [:]
    private let disposeBag = DisposeBag()
    
    public func fetchTemplates(appBundle: String) -> Observable<TemplateListResponce> {
        Observable.empty()
    }
    
    public func fetchPhotoTemplates(appBundle: String) -> Observable<PhotoTemplateListResponce> {
        Observable.empty()
    }
    
    public func generatePhoto(from prompt: String, userID: String, appBundle: String) -> Observable<PhotoResult> {
        Observable<Int>.timer(.seconds(3), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .map { _ in
                PhotoResult(url: "https://trust.coreapis.space/static/large/bc16f124b6bb4370883051b7262f687e.jpg", detail: "Success")
            }
    }
    
    public func generatePhoto(from prompt: String, usingImage data: Data, imageName: String, userID: String, appBundle: String) -> Observable<PhotoResult> {
        Observable<Int>.timer(.seconds(3), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .map { _ in
                PhotoResult(url: "https://trust.coreapis.space/static/large/bc16f124b6bb4370883051b7262f687e.jpg", detail: "Success")
            }
    }
    
    public func generatePhoto(byTemplateID id: String, usingImage data: Data, imageName: String, userID: String, appBundle: String) -> Observable<PhotoResult> {
        Observable<Int>.timer(.seconds(3), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .map { _ in
                PhotoResult(url: "https://trust.coreapis.space/static/large/bc16f124b6bb4370883051b7262f687e.jpg", detail: "Success")
            }
    }
    
    public func generateVideo(from prompt: String, userID: String, appBundle: String) -> RxSwift.Observable<VideoGenerationTask> {
        let videoID = Int.random(in: 100...999)
        let videoRequest = VideoGenerationTask(video_id: videoID, detail: "success")
        let createdVideo = VideoResult(status: "generating", video_url: "")
        self.createdVideos[videoID] = createdVideo
        
        Observable<Int>.timer(.seconds(6), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { _ in
                let video = VideoResult(status: "success", video_url: "https://trust.coreapis.space/static/video/large/3c81864e2f164799a522873170e783d7.mp4")
                self.createdVideos[videoID] = video
            })
            .disposed(by: disposeBag)
        
        return Observable.just(videoRequest)
    }
    
    public func generateVideo(from prompt: String, usingImage data: Data, imageName: String, userID: String, appBundle: String) -> RxSwift.Observable<VideoGenerationTask> {
        self.generateVideo(from: "", userID: "", appBundle: "")
    }
    
    public func generateVideo(byTemplateID id: String, usingImage data: Data, imageName: String, userID: String, appBundle: String) -> RxSwift.Observable<VideoGenerationTask> {
        self.generateVideo(from: "", userID: "", appBundle: "")
    }
    
    public func checkStatus(requestID: String) -> RxSwift.Observable<VideoResult> {
        let response = createdVideos[Int(requestID)!]
        return Observable.just(response!)
    }
    
    public func handleVideoGenerationStatus(videoID: String) -> RxSwift.Observable<(String, VideoResult)> {
        return Observable<Int>.interval(.seconds(2), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { _ -> Observable<(String, VideoResult)> in
                self.checkStatus(requestID: videoID)
                    .map { (videoID, $0) }
            }
            .share()
    }
    

}
