# frozen_string_literal: true

class ProcessHashtagsService < BaseService
  def call(status, tags = [])
    tags = Extractor.extract_hashtags(status.text) if status.local?

    if !(tags.include?('precure_chat'))
      if Rails.configuration.x.default_hashtag.present? && status.visibility == 'public' && status.local? then
        tags << Rails.configuration.x.default_hashtag
      end
    end
    
    tags.map { |str| str.mb_chars.downcase }.uniq(&:to_s).each do |name|
      tag = Tag.where(name: name).first_or_create(name: name)
      status.tags << tag
      TrendingTags.record_use!(tag, status.account, status.created_at) if status.public_visibility?
    end
  end
end
