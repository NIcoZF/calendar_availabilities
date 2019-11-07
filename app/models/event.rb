class Event < ActiveRecord::Base

  validates :starts_at, :ends_at, presence: true,
                                format: { with: /\d{4}-\d{2}-\d{2}\s\d{1,2}:\d{1,2}:\d{1,2}/ }

 

  def self.availabilities(date)

    # week_availabilities = [] array of hashes, containing date + 6 following days

    week_availabilities = []

    (1..7).each do 
      week_availabilities.push({ date: "#{date.strftime("%Y\/%m\/%d")}", slots: available_slots })
      date += 1
    end
  end

    def available_slots(date)
      ## Scoping
      # add scope to get a day in a week
      next_day = date + 1
      scope :daily, -> (date, next_day) { 
        where("starts_at >= ? AND ends_at < ?", date, next_day )
      }
      scope :opening, -> { where(kind: "opening") }
      # add scope daily appointment 
      
      # retrieve openings and appointments for each date 

      openings = Event.daily.opening # Event.where("starts_at >= ? AND ends_at < ? AND kind = ?", date, date+1, 'opening')
      appointments = Event.where("starts_at >= ? AND kind = ?", date, 'appointment')

      openings

    end
    
   

    #date.strftime("%Y%m%d"))

    
    # each slots are split by 30 min

end
