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

  embedded_in :profile
end
