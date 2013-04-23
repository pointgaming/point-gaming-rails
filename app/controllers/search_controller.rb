class SearchController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html, :json

  def index
    options = params
    page = (options[:page] || 1).to_i
    search_size = options[:per] || 25

    @results = Tire.search(["games", "streams", "teams", "users", "forem_posts", "spree_products"]) do |search|
      if options[:query].present?
        search.query do
          boolean do
            must { string "prefix:#{options[:query]} OR #{options[:query]}" }
          end
        end
      end
      search.highlight '_all'
      search.sort { by "main_sort", 'asc' }
      search.from (page -1) * search_size
      search.size search_size
    end

    @results = @results.results

    respond_with(@results)
  end

  def playable
    @results = []
    @results += User.where(username: /#{Regexp.escape(params[:query])}/i).all
    @results += Team.where(name: /#{Regexp.escape(params[:query])}/i).all

    Kaminari.paginate_array(@results).page(params[:page])

    respond_with(@results)
  end
end
