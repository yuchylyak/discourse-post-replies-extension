# frozen_string_literal: true

# name: post-replies-extension
# about: Used for having all reply ids in post-stream object
# version: 1.0.0
# authors: Zero Dev

after_initialize do
  module ::PostStreamSerializerMixin
    def post_stream
      result = { posts: posts }

      if include_stream?
        if !object.is_mega_topic?
          result[:stream] = object.filtered_post_ids
        else
          result[:isMegaTopic] = true
          result[:firstId] = object.first_post_id
          result[:lastId] = object.last_post_id
        end
      end

      if include_gaps? && object.gaps.present?
        result[:gaps] = GapSerializer.new(object.gaps, root: false)
      end

      stream_posts = Post.where(id: result[:stream])

      result[:post_replies] = stream_posts.each_with_object({}) do |post, replies|
        replies[post.id] = stream_posts.select { |reply_post| reply_post.reply_to_post_number == post.post_number }.map(&:id)
      end

      result
    end
  end
end
