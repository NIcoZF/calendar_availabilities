class Event < ActiveRecord::Base

  validates :starts_at, :ends_at, presence: true,
                                format: { with: /\d{4}-\d{2}-\d{2}\s\d{1,2}:\d{1,2}:\d{1,2}/ }
  # check for kind attribute
  # check for starts-at before ends_at

 

  def self.availabilities(date)
    # week_availabilities = [] array of hashes, containing date + 6 following days
    week_availabilities = []
    available_slots = []

    7.times do
      week_availabilities << { date: date, slots: available_slots(date) }
      date += 1
    end
    week_availabilities
  end

  def self.available_slots(date)
    next_day = date + 1
    openings = []
    openings = Event.where('starts_at >= ? AND ends_at < ?',
                           date, next_day).where(kind: 'opening')
    appointments = []
    appointments = Event.where('starts_at >= ? AND ends_at < ?',
                               date, next_day).where(kind: 'appointment')

    opening_slots = []

    unless openings.empty?
      time_slot = openings[0][:starts_at]
      while time_slot < openings[0][:ends_at]
        opening_slots << time_slot.strftime('%R')
        time_slot += 30.minutes
      end
    end

    close_slots = []

    unless appointments.empty?
      time_slot = appointments[0][:starts_at] # - 30.minutes
      while time_slot < appointments[0][:ends_at]
        close_slots << time_slot.strftime('%R')
        time_slot += 30.minutes
      end
    end

    free_slots = opening_slots - close_slots
  end
end
