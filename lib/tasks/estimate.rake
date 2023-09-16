require 'csv'

namespace :estimate do
  def fetch_locations_for_address(address, retailer:)
    if retailer == :cvs
    elsif retailer == :walgreens
      
    end
  end

  def cached(cache_keys, data_type:) do
    Cache.where(cache_key: cache_keys.join("-")).first_or_create do |cache|
      data = yield
      cache.data = JSON.dump(data)
      cache.data_type = data_type
      cache.save!
    end
  end

  task vaccines: :environment do
    zip_codes.each do |zip_code|
      [:cvs, :walgreens].each do |retailer|
        locations = cached([zip_code, retailer], data_type: :search) do
          fetch_locations_for_address(zip_code, retailer:)
        end
      end
    end
  end
end