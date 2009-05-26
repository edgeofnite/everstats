class Node < ActiveRecord::Base
    has_many :dayusages
    has_many :samples
end
