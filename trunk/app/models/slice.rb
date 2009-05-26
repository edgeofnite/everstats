class Slice < ActiveRecord::Base
    belongs_to :slicegroup
    has_many :dayusages
    has_many :samples
end
