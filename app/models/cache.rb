class Cache < ApplicationRecord
  enum data_type: {
    locations: 0,
    availabilities: 1,
  }
end
