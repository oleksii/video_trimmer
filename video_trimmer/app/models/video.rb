class Video
  include Mongoid::Document
  include VideoUploader[:file]

  belongs_to :user

  field :file_data, type: Hash
  field :duration,  type: String

  embeds_one :timeline
  embeds_one :trim

  validates_presence_of :file
  validates_with TimelineValidator
end
