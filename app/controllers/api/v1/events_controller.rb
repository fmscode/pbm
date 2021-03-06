module Api
  module V1
    class EventsController < InheritedResources::Base
      before_filter :allow_cors
      respond_to :json
      has_scope :region

      api :GET, '/api/v1/region/:region/events.json', 'Get all events for a single region'
      param :region, String, desc: 'Name of the Region you want to see events for', required: true
      param :sorted, String, desc: 'If value is present, sort/group by event category', required: false
      formats ['json']
      def index
        events = apply_scopes(Event)

        events.select! { |e| e.end_date ? (e.end_date >= Date.today - 7) : e }
        events.select! { |e| (e.start_date && !e.end_date) ? (e.start_date >= Date.today - 7) : e }

        if params[:sorted] && events.size > 0
          apply_special_sort_and_respond(events)
        else
          apply_regular_sort_and_respond(events)
        end
      end

      def apply_regular_sort_and_respond(events)
        events.sort! do |x, y|
          if x.start_date && y.start_date
            x.start_date <=> y.start_date
          else
            x.start_date ? -1 : 1
          end
        end
        return_response(events, 'events')
      end

      def apply_special_sort_and_respond(events)
        sorted_events = {}

        events.each do |e|
          category = e.category.blank? ? 'General' : e.category
          (sorted_events[category] ||= []) << e
        end

        return_response([sorted_events], 'events')
      end
    end
  end
end
