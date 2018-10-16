class Trim
  include Mongoid::Document
  include SimpleEnum::Mongoid

  as_enum :status, [:scheduled, :processing, :failed, :done], field: { :type => Integer, :default => 0 }

  embedded_in :video
end
