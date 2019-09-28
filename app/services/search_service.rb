# frozen_string_literal: true

class SearchService < BaseService
  def call(query, account, limit, options = {})
    @query   = query.strip
    @account = account
    @options = options
    @limit   = limit.to_i
    @offset  = options[:type].blank? ? 0 : options[:offset].to_i
    @resolve = options[:resolve] || false

    default_results.tap do |results|
      if url_query?
        results.merge!(url_resource_results) unless url_resource.nil? || (@options[:type].present? && url_resource_symbol != @options[:type].to_sym)
      elsif @query.present?
        results[:accounts] = perform_accounts_search! if account_searchable?
        results[:statuses] = perform_statuses_search!
        results[:statuses].concat(perform_mediadescription_search!)
        results[:statuses] = results[:statuses].uniq.sort_by{|v| v['updated_at']}.reverse.first(@limit)
        results[:hashtags] = perform_hashtags_search! if hashtag_searchable?
      end
    end
  end

  private

  def perform_accounts_search!
    AccountSearchService.new.call(
      @query,
      @account,
      limit: @limit,
      resolve: @resolve,
      offset: @offset
    )
  end

  def perform_statuses_search!
    statuses = Status.joins(:account)
      .where('accounts.domain IS NULL')
      .where('statuses.local=true')
      .limit(@limit)
    @query.split(/[\s　]+/).each do |keyword|
      if (matches = keyword.match(/^-(.*)/))
        keyword = matches[1]
        statuses = statuses.where('statuses.text !~ ?', keyword)
      else
        statuses = statuses.where('statuses.text ~ ?', keyword)
      end
    end
    statuses.reject { |status| StatusFilter.new(status, @account).filtered? }
  rescue Faraday::ConnectionFailed
    []
  end

  def perform_mediadescription_search!
    medias = Status
      .joins(:account)
      .joins(:media_attachments)
      .where('accounts.domain IS NULL')
      .where('statuses.local=true')
      .limit(@limit)
    @query.split(/[\s　]+/).each do |keyword|
      if (matches = keyword.match(/^-(.*)/))
        keyword = matches[1]
        medias = medias.where('media_attachments.description !~ ?', keyword)
      else
        medias = medias.where('media_attachments.description ~ ?', keyword)
      end
    end
    medias.reject { |status| StatusFilter.new(status, @account).filtered? }
  rescue Faraday::ConnectionFailed
    []
  end

  def perform_hashtags_search!
    TagSearchService.new.call(
      @query,
      limit: @limit,
      offset: @offset
    )
  end

  def default_results
    { accounts: [], hashtags: [], statuses: [] }
  end

  def url_query?
    @resolve && @query =~ /\Ahttps?:\/\//
  end

  def url_resource_results
    { url_resource_symbol => [url_resource] }
  end

  def url_resource
    @_url_resource ||= ResolveURLService.new.call(@query, on_behalf_of: @account)
  end

  def url_resource_symbol
    url_resource.class.name.downcase.pluralize.to_sym
  end

  def full_text_searchable?
    return false unless Chewy.enabled?

    statuses_search? && !@account.nil? && !((@query.start_with?('#') || @query.include?('@')) && !@query.include?(' '))
  end

  def account_searchable?
    account_search? && !(@query.include?('@') && @query.include?(' '))
  end

  def hashtag_searchable?
    hashtag_search? && !@query.include?('@')
  end

  def account_search?
    @options[:type].blank? || @options[:type] == 'accounts'
  end

  def hashtag_search?
    @options[:type].blank? || @options[:type] == 'hashtags'
  end

  def statuses_search?
    @options[:type].blank? || @options[:type] == 'statuses'
  end

  def relations_map_for_account(account, account_ids, domains)
    {
      blocking: Account.blocking_map(account_ids, account.id),
      blocked_by: Account.blocked_by_map(account_ids, account.id),
      muting: Account.muting_map(account_ids, account.id),
      following: Account.following_map(account_ids, account.id),
      domain_blocking_by_domain: Account.domain_blocking_map_by_domain(domains, account.id),
    }
  end

  def parsed_query
    SearchQueryTransformer.new.apply(SearchQueryParser.new.parse(@query))
  end
end
