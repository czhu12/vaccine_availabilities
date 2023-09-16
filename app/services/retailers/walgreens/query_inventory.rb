# frozen_string_literal: true

class Retailers::Walgreens::QueryInventory < Retailers::QueryInventory
  def self.example # rubocop:disable Metrics/MethodLength
    example!(location: Location.find_or_create_by(
      external_id: '336270e3-ea73-4d6a-9a4f-3a6a243004d6',
      location_type: LocationType.find_or_create_by(retailer: :walgreens),
      address_1: '2140 EL CAMINO REAL',
      city: 'Santa Clara',
      state: 'CA',
      zip_code: '95050',
      longitude: -121.96147839,
      latitude: 37.35173795,
      name: 'Walgreen Drug Store'
    ))
  end

  def query
    response = Retailers::Walgreens::QueryLocations.new.fetch(
      Query::LocationSearch.new(
        address: Query::Address.new(
          zip_code: location.zip_code, latitude: location.latitude.to_f,
          longitude: location.longitude.to_f
        ),
        services:
      ),
      query_date_range: date_range
    )
    create_time_slots(response)
  end

  def create_time_slots(response)
    slot_data(response).flat_map do |day|
      day['slots'].map do |time|
        parsed_time = parse_time("#{day['date']} #{time}")
        next unless within_date_range(parsed_time)

        TimeSlot.new(
          location_id: location.id,
          time: parsed_time
        )
      end
    end.compact
  end

  def slot_data(response)
    location_data = response['locations'].find do |data|
      data['locationId'] == location.external_id
    end
    location_data['appointmentAvailability']
  end

  def parse_time(time_string)
    with_time_zone.strptime(time_string, '%Y-%m-%d %I:%M %p')
  end
end
