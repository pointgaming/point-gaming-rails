class Rig
  include Mongoid::Document

  field :manufacturer, type: String
  field :case, type: String
  field :power_supply, type: String
  field :operating_system, type: String
  field :motherboard, type: String
  field :cpu, type: String
  field :memory, type: String
  field :hard_drive, type: String
  field :hard_drive_2, type: String
  field :hard_drive_3, type: String
  field :video_card, type: String
  field :sound_card, type: String
  field :headphones, type: String
  field :headphone_amp, type: String
  field :headset, type: String
  field :microphone, type: String
  field :monitor, type: String
  field :mouse, type: String
  field :mousepad, type: String
  field :keyboard, type: String

  # add a _url field and validation for all of the fields above (except a few)
  attribute_names.select{|x| [:_type, :_id].include?(x.to_sym) === false}.each do |field_name|
    field :"#{field_name}_url", type: String
    validates_each :"#{field_name}_url" do |record, attr, value|
      record.send("#{attr}=", "") unless value =~ Regexp.new("^#{APP_CONFIG[:store_url]}")
    end
  end

  embedded_in :profile

end
