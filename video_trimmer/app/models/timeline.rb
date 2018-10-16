class Timeline
  include Mongoid::Document

  field :start_time, type: String
  field :end_time,   type: String

  embedded_in :video
end
