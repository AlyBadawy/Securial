module Securial
  class <%= controller_class_name %>Controller < ApplicationController
    before_action :set_<%= singular_table_name %>, only: [:show, :update, :destroy]

    def index
      @<%= plural_table_name %> = <%= orm_class.all(class_name) %>
    end

    def show
    end

    def create
      @<%= singular_table_name %> = <%= orm_class.build(class_name, "#{singular_table_name}_params") %>

      if @<%= singular_table_name %>.save
        render :show, status: :created, location: @<%= singular_table_name %>
      else
        render json: @<%= singular_table_name %>.errors, status: :unprocessable_entity
      end
    end

    def update
      if @<%= singular_table_name %>.update(<%= singular_table_name %>_params)
        render :show
      else
        render json: @<%= singular_table_name %>.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @<%= singular_table_name %>.destroy
    end

    private

    def set_<%= singular_table_name %>
      @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    end

    def <%= singular_table_name %>_params
      params.expect(<%= singular_table_name %>: [<%= attributes_names.map { |name| ":#{name}" }.join(', ') %>])
    end
  end
end