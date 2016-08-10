require 'active_support/inflector'
require_relative 'assoc_options'

class HasManyOptions < AssocOptions
  attr_reader :foreign_key, :primary_key, :class_name

  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || (self_class_name.downcase.to_s + "_id").to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
  end
end
