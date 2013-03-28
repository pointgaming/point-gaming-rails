module DeviseFilters

  def self.add_filters
    DeviseController.before_filter do
      @hide_nav = true
    end
  end

  self.add_filters
end
