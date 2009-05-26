class Sample < ActiveRecord::Base
    belongs_to :slice
    belongs_to :node
end
