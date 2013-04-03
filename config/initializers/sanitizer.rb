embedded_transformer = lambda {|options|
  node = options[:node]
  return unless node.present? && node.element? && ['object', 'iframe'].include?(node.name)

  node['width'] = "590"
  node['height'] = "360"
}

Sanitize::Config::EMBEDDED_CONTENT = {
  :elements => %w[
    iframe object param a
  ],

  :attributes => {
    :all => ['dir', 'lang', 'title'],
    'iframe' => ['width', 'height', 'src', 'frameborder', 'allowfullscreen'],
    'object' => ['type', 'height', 'width', 'data'],
    'param' => ['name', 'value'],
    'a' => ['href']
  },

  :transformers => [embedded_transformer],

  :protocols => {
    'iframe' => {'src' => ['http', 'https']},
    'object' => {'data' => ['http', 'https']},
    'a' => {'href' => ['http', 'https', :relative]}
  }
}
