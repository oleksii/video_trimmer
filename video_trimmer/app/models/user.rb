class User
  include Mongoid::Document

  has_many :videos, dependent: :destroy
end
