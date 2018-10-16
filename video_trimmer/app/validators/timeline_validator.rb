class TimelineValidator < ActiveModel::Validator
  ST_LESS_THEN_ZERO = 'start_time must be greater or equal zero'
  ST_LESS_THEN_ET   = 'start_time must be less then end_time'
  ET_LESS_OR_ZERO   = 'end_time must be greater then zero'

  def validate(record)
    start_time = record.timeline.start_time.to_f
    end_time   = record.timeline.end_time.to_f

    record.errors[:timeline] << ST_LESS_THEN_ZERO if start_time < 0
    record.errors[:timeline] << ET_LESS_OR_ZERO   if end_time   <= 0
    record.errors[:timeline] << ST_LESS_THEN_ET   if start_time >= end_time
  end
end
