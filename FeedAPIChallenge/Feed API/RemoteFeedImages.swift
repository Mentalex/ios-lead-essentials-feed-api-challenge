//
//  RemoteFeedImages.swift
//  FeedAPIChallenge
//
//  Created by Alex Tapia on 10/08/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal struct RemoteFeedImages {
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

	internal static func feedImages(from data: Data, and response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteFeedLoader.Error.invalidData
		}
		return root.items.map { $0.image }
	}
}
