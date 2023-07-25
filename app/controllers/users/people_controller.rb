module Users
  class PeopleController < ApplicationController
    def index
      @meta, @people = pagy(User.all, page: page_num)
      as_success(
        people: ListSerializer.new(@people, serializer: PeopleSerializer),
        pagination: {
          previous: @meta.prev,
          current: @meta.page,
          next: @meta.next,
          pages: @meta.pages
        }
      )
    end

    private

    def page_num
      num = params[:page].to_i
      num.zero? ? 1 : num
    end
  end
end
