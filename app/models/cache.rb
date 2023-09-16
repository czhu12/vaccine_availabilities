class Cache < ApplicationRecord
  enum data_type: {
    locations: 0,
    availabilities: 1,
    search: 2,
    walgreens_locations: 3,
  }
end
