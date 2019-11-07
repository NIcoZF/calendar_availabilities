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
      week_availabilities.push({ date: "#{date.strftime("%Y\/%m\/%d")}", slots: available_slots(date) })
      date += 1
    end
      p week_availabilities.inspect
  end

    def self.available_slots(date)

      # retrieve the opening and appointments of the day

      next_day = date + 1
     
      openings = Event.where("starts_at >= ? AND ends_at < ?", date, next_day ).where(kind: "opening")
      appointments = Event.where("starts_at >= ? AND ends_at < ?", date, next_day ).where(kind: "appointment")

      openings

    end
    
   

    #date.strftime("%Y%m%d"))

    
    # each slots are split by 30 min

end
