require 'csv'
ZIP_CODE_CSV = CSV.parse(
  File.read(File.join('lib', 'assets', 'zip_codes.csv')),
  headers: true 
)
namespace :estimate do
  def fetch_locations_for_address(address, retailer:)
    if retailer == :cvs
    elsif retailer == :walgreens
      
    end
  end

  def cached(cache_keys, data_type:) do
    Cache.where(key: cache_keys.join("-")).first_or_create do |cache|
      data = yield
      cache.data = JSON.dump(data)
      cache.data_type = data_type
      cache.save!
    end
  end

  def zip_codes
    ZIP_CODE_CSV.map do |row|
      row['zipcode']
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