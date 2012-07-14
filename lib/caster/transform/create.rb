module Caster
  class Create

    def initialize params
      @params_template = params
    end

    def execute doc
      params = @params_template.clone
      params.each do |field, value|
        if value.is_a? Reference
          params[field] = value.evaluate doc
        end
      end
      params
    end
  end
end