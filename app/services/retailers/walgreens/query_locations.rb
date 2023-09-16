# frozen_string_literal: true

class Retailers::Walgreens::QueryLocations < Retailers::QueryLocations
  def service_ids(services)
    Retailers::Walgreens::QueryServices
      .new(services:)
      .codes
      .map { |code| { code:, productId: '' } }
  end

  def client
    @client ||= Retailers::Walgreens::Client.new
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def fetch(location_search, query_date_range: nil)
    client.post(
      '/hcschedulersvc/svc/v7/immunizationLocations/timeslots',
      {
        position: {
          latitude: location_search.address.latitude,
          longitude: location_search.address.longitude
        },
        state: location_search.address.state,
        vaccine: service_ids(location_search.services),
        appointmentAvailability: {
          startDateTime: (query_date_range || date_range).begin.to_s
        },
        filter: {
          radius: location_search.radius,
          size: 25,
          pageNo: 1,
          includeUnavailableStores: false
        },
        serviceId: '99',
        restriction: {
          dob: 18.years.ago.strftime('%Y-%m-%d')
        }
      }
    )
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  private

    def fetch_store_data(location_search) # rubocop:disable Metrics/MethodLength
      @store_data = client.post(
        '/locator/v1/stores/search?requestor=search',
        {
          r: location_search.radius,
          requestType: 'dotcom',
          s: 25, # size
          p: 1, # page
          q: '', # idk
          lat: location_search.address.latitude,
          lng: location_search.address.longitude
        }
      )['results']
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def create_locations(response)
      locations_data = response.with_indifferent_access[:locations]
      location_type = LocationType.find_or_create_by(retailer: :walgreens)
      locations_data.map do |data|
        location_type
          .locations
          .find_or_initialize_by(external_id: data[:locationId])
          .tap do |location|
          location.assign_zip_time_zone
          location.update!(
            name: data[:name],
            address_original_attributes: {
              address_1: data[:address][:line1],
              address_2: data[:address][:line2],
              city: data[:address][:city],
              state: data[:address][:state],
              zip_code: data[:address][:zip],
              latitude: data[:position][:latitude],
              longitude: data[:position][:longitude]
            },
            latitude: data[:position][:latitude],
            longitude: data[:position][:longitude],
            metadata: location_metadata(data),
            retailer: 'walgreens',
            parent_retailer: 'walgreens'
          )
        end
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def web_address(data)
      "https://www.walgreens.com/locator/walgreens/id=#{data[:storenumber]}"
    end

    def location_metadata(data)
      metadata = super.merge({
                               organization_id: data[:orgId],
                               phone_number: data[:phone].find { |x| x[:type] == 'Pharmacy' }&.dig(:number),
                               web_address: web_address(data)
                             })

      location_data = store_data.find { |store| store['storeNumber'] == data['storenumber'] }
      metadata.merge({ open_hours: open_hours(location_data) })
    end

    def open_hours(data)
      return [] if data.blank?

      data = data['store']
      times = { open_time: data['pharmacyOpenTime'], close_time: data['pharmacyCloseTime'] }
      hours = Retailers::Base::WEEKDAYS.map do |day|
        parse_times(**times.merge(day:))
      end

      hours << parse_times(**times.merge(day: 'sat'))
      hours << parse_times(**times.merge(day: 'sun'))
      hours
    end
end
