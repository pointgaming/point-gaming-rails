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

  :protocols => {
    'iframe' => {'src' => ['http', 'https']},
    'object' => {'data' => ['http', 'https']},
    'a' => {'href' => ['http', 'https', :relative]}
  }
}
