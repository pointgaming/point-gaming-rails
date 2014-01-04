# Added ability to search multiple paths when searching for a rabl view
RablRails::Renderer::LookupContext.class_eval do

  # hardcoded @view_path
  def initialize(_, format)
    @view_path = ActionView::PathSet.new(['app/views', PointGaming.views_path])
    @format = format.to_s.downcase
  end

  def find_template(path, opt, partial = false)
    path = File.join("#{path}.#{@format}")
    name = File.basename(path)
    path.slice!("/#{name}")
    file = @view_path.find(name, [path], partial, {
      locale: [:en],
      formats: [:html],
      handlers: [:erb, :builder, :rabl]
    }, {})
    file.present? ? file : nil
  end

end
