//
//  RemoteFeedImages.swift
//  FeedAPIChallenge
//
//  Created by Alex Tapia on 10/08/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct FeedImagesMapper {
	private struct Root: Decodable {
		let items: [RemoteFeedImage]
	}

	private struct RemoteFeedImage: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var image: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	static func map(from data: Data, and response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteFeedLoader.Error.invalidData
		}
		return root.items.map { $0.image }
	}
}
