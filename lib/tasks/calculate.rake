$stdout.sync = true
require 'csv'
require "uri"
require "json"
require "net/http"

namespace :calculate do
  def calculate_cvs
    output_file = Rails.root.join('lib', 'assets', "calculated_cvs-#{Date.today.to_s}.csv")

    found_stores = []
    by_zip_code = {}
    Cache.cvs_locations.each do |cache|
      ndc = cache.key.split("--").last
      json = JSON.parse(cache.value)
      next if json.dig('responseMetaData', 'statusCode') == '1010'
      json.dig('responsePayloadData', 'locations').each do |location|
        store_number = location['StoreNumber']
        uid = "#{store_number}-#{ndc}"
        next if found_stores.include?(uid)
        found_stores << uid 
        by_zip_code[location['addressZipCode']] ||= {count: 0, ndc: ndc} 
        by_zip_code[location['addressZipCode']][:count] = by_zip_code[location['addressZipCode']][:count] + (14 * 10) # 14 days plus 10 slots
      end
    end

    CSV.open(output_file, 'w', write_headers: true, headers: %w[zipcode count ndc]) do |writer|
      by_zip_code.each do |k, v|
        writer << [k, v[:count], v[:ndc]]
        print('.')
      end
    end
  end
  
  def get_calculation(retailer)
    if retailer == :cvs
      calculate_cvs
    elsif retailer == :walgreens
      calculate_walgreens
    end
  end

  def calculate_walgreens
  end

  task calculate: :environment do
    [:cvs, :walgreens].each do |retailer|
      get_calculation(retailer) 
    end
  end
end