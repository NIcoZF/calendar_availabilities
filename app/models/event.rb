# frozen_string_literal: true

class Event < ActiveRecord::Base
  validates :starts_at, :ends_at, presence: true,
                                  format: { with: /\d{4}-\d{2}-\d{2}\s\d{1,2}:\d{1,2}:\d{1,2}/ }
  # validate :future_event
  validates :kind, inclusion: { in: %w(opening appointment) }

  def self.availabilities(date)
    # week_availabilities = [] array of hashes, containing date + 6 following days
    week_availabilities = [{ date: date, slots: [] }]
    # available_slots = []
    6.times do
      week_availabilities << { date: date += 1, slots: [] }
    end

    week_availabilities.each do |event|
      next if event[:date].cwday == 7

      opening = available_slots(event[:date])
      close = close_slots(event[:date])
      event[:slots] = opening - close
    end
    week_availabilities
  end

  def self.available_slots(date)
    # retrieve daily opening with the input date or weekly_recurring slot
    openings = Event.where(kind: 'opening').where('starts_at >= ? AND ends_at < ? OR weekly_recurring =?',
                                                  date, date + 1, true)

    opening_slots = []

    unless openings.empty?
      time_slot = openings[0][:starts_at]
      while time_slot < openings[0][:ends_at]
        opening_slots << time_slot.strftime('%k:%M').strip
        time_slot += 30.minutes
      end
    end
    opening_slots
  end

  def self.close_slots(date)
    # retrieve daily appointment with input date slot
    appointments = Event.where(kind: 'appointment').where('starts_at >= ? AND ends_at < ?',
                                                          date, date + 1)
    close_slots = []

    unless appointments.empty?
      time_slot = appointments[0][:starts_at]
      while time_slot < appointments[0][:ends_at]
        close_slots << time_slot.strftime('%k:%M').strip
        time_slot += 30.minutes
      end
    end
    close_slots
  end

  private

  def future_event
    errors.add(:starts_at, "Can't be in the past!") if starts_at < Time.now
  end
end
