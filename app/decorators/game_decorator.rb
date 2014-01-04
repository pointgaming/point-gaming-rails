class GameDecorator < Draper::Decorator

  def html_class
    model.name.gsub(/[^\w]/, '')
  end

  def image_name
    "games/#{html_class}.png"
  end

end
