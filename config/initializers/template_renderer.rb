# this will allow us to get the name of the view file being rendered from within a view
#
class ActionController::Base
  attr_accessor :active_template

  def active_template_virtual_path
    self.active_template.virtual_path if self.active_template
  end
end

class ActionView::TemplateRenderer 

  alias_method :_render_template_original, :render_template

  def render_template(template, layout_name = nil, locals = {})
    @view.controller.active_template = template if @view.controller
    result = _render_template_original( template, layout_name, locals)
    @view.controller.active_template = nil if @view.controller
    return result
  end

end
