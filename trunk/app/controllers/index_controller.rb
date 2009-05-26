class IndexController < ApplicationController
    layout "standard-layout"
    def index
        render_text "index!"
    end
end
