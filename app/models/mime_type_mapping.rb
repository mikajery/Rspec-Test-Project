class MimeTypeMapping < ActiveRecord::Base
  # We can add more category names here if we want to provide support for more granular attachment filtering
  as_enum :usable_category, other: 0, image: 1, document: 2

  validates_uniqueness_of :mime_type
end
