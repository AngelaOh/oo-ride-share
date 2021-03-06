require "csv"
require "time"

require_relative "csv_record"

module RideShare
  class Trip < CsvRecord
    attr_reader :id, :passenger, :passenger_id, :start_time, :end_time, :cost, :rating, :driver, :driver_id

    def initialize(id:,
                   passenger: nil, passenger_id: nil,
                   start_time:, end_time: nil, cost: nil, rating: nil, driver_id: nil, driver: nil)
      super(id)

      if passenger
        @passenger = passenger
        @passenger_id = passenger.id
      elsif passenger_id
        @passenger_id = passenger_id
      else
        raise ArgumentError, "Passenger or passenger_id is required"
      end

      @start_time = Time.parse(start_time)
      if end_time == nil
        puts "^^^^^^Trip in progress - end_time pending, current #{end_time.class}"
      else
        @end_time = Time.parse(end_time)
      end
      @cost = cost
      @rating = rating

      if driver
        @driver = driver
        @driver_id = driver.id
      elsif driver_id
        @driver_id = driver_id
      else
        raise ArgumentError, "Driver or driver_id is required"
      end

      if end_time == nil
        puts "^^^^^^Trip in progress - duration of trip calculation pending, current #{end_time.class}"
      elsif end_time < start_time
        raise ArgumentError, "End time is before start time"
      end

      if @rating == nil
        puts "^^^^^^Trip in progress - rating pending, current #{@rating.class}"
      elsif @rating > 5 || @rating < 1
        raise ArgumentError.new("Invalid rating #{@rating}")
      end
    end

    def duration_trip
      if @end_time == nil
        return nil
      end

      duration_seconds = (@end_time - @start_time)
      return duration_seconds
    end

    def inspect
      # Prevent infinite loop when puts-ing a Trip
      # trip contains a passenger contains a trip contains a passenger...
      "#<#{self.class.name}:0x#{self.object_id.to_s(16)} " +
      "ID=#{id.inspect} " +
      "PassengerID=#{passenger&.id.inspect}>"
    end

    def connect_passenger(passenger)
      @passenger = passenger
      passenger.add_trip(self)
    end

    def connect_driver(driver)
      @driver = driver
      driver.add_trip(self)
    end

    private

    def self.from_csv(record)
      return self.new(
               id: record[:id],
               passenger_id: record[:passenger_id],
               start_time: record[:start_time],
               end_time: record[:end_time],
               cost: record[:cost],
               rating: record[:rating],
               driver_id: record[:driver_id],
             )
    end
  end
end
