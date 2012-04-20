module Utensils
  module CustomMatchers
    class HaveModel
      def initialize(model)
        @model_id = ApplicationController.helpers.dom_id(model)
      end

      def matches?(page)
        @page = page
        @page.has_css?("##{@model_id}")
      end

      def failure_message_for_should
        "expected #{@page.body} to contain element with id: #{@model_id}"
      end

      def failure_message_for_should_not
        "expected #{@page.body} to not contain element with id: #{@model_id}"
      end
    end

    def have_model(model)
      HaveModel.new(model)
    end

    class HaveClass
      def initialize(class_name)
        @class_name = class_name
      end

      def matches?(element)
        @element = element
        @element[:class] == @class_name
      end

      def failure_message_for_should
        "expected #{@element.tag_name} to have class #{@class_name} but had #{@element[:class]}"
      end

      def failure_message_for_should_not
        "expected #{@element.tag_name} to not have class #{@class_name} but it did"
      end
    end

    def have_class(class_namel)
      HaveClass.new(class_namel)
    end

    class Disabled
      def matches?(element)
        @element = element
        @element[:disabled] == "disabled"
      end

      def failure_message_for_should
        "expected #{@element.tag_name} to be disabled but it wasn't"
      end

      def failure_message_for_should_not
        "expected #{@element.tag_name} not to be disabled but it was"
      end
    end

    def disabled?
      Disabled.new
    end

    class HaveImage
      def initialize(image)
        @image = image
      end

      def matches?(page)
        @page = page
        @image.is_a?(String) ? find_by_url : find_dragonfly_image
      end

      def failure_message_for_should
        "expected #{@page.body} to contain image: #{@image.inspect}"
      end

      def failure_message_for_should_not
        "expected #{@page.body} to not contain image: #{@image.inspect}"
      end

      private

      def find_by_url
        @page.has_css?("img[src='#{@image}']")
      end

      def find_dragonfly_image
        @page.all('img').each do |img|
          url = img['src']
          dragonfly_hash = url[/media\/([^\/.]+)/, 1]
          if dragonfly_hash
            dragonfly_job = Dragonfly::Job.deserialize(dragonfly_hash, Dragonfly[:images])
            return true if dragonfly_job.uid == @image.send(:uid)
          end
        end
        return false
      end
    end

    def have_image(image_url)
      HaveImage.new(image_url)
    end

    class Ordered
      def initialize(args)
        @within = args.pop[:within]
        @models = args
      end

      def matches?(page)
        @page = page
        @models.each_with_index do |model,i|
          return false unless @page.has_css?("#{@within} ##{ApplicationController.helpers.dom_id(model)}:nth-child(#{i+1})")
        end
        true
      end

      def failure_message_for_should
        "expected #{@page.body} to have models in this order: #{@models.inspect}"
      end

      def failure_message_for_should_not
        "expected #{@page.body} to not have models in this order: #{@models.inspect}"
      end
    end

    def have_order(*args)
      Ordered.new(args)
    end
  end
end

RSpec.configure do |config|
  config.include(Utensils::CustomMatchers, :type => :request)
end
