//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }

			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				if response.statusCode == 200 {
					do {
						let images = try RemoteFeedImages.feedImages(from: data)
						completion(.success(images))
					} catch {
						completion(.failure(Error.invalidData))
					}
				} else {
					completion(.failure(Error.invalidData))
				}
			}
		}
	}
}

private struct RemoteFeedImages {
	private struct Root: Decodable {
		let items: [RemoteFeedImage]
	}

	private struct RemoteFeedImage: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let url: URL

		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}

		var image: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}
	}

	static func feedImages(from data: Data) throws -> [FeedImage] {
		return try JSONDecoder().decode(Root.self, from: data).items.map { $0.image }
	}
}
