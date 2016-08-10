require_relative 'belongs_to_options'
require_relative 'has_many_options'

module Associatable

  def has_one_through(name, through_name, source_name)
    define_method name do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      res = DBConnection.execute(<<-SQL, self.send(through_options.foreign_key))
        SELECT
          #{source_options.table_name}.*
        FROM
          #{source_options.table_name}
        JOIN
          #{through_options.table_name} ON
          #{through_options.table_name}.#{source_options.foreign_key} =
          #{source_options.table_name}.#{through_options.primary_key}
        WHERE
          #{through_options.table_name}.#{through_options.primary_key} = ?
      SQL

      source_options.model_class.new(res.first)
    end
  end

  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method name do
      foreign_key = self.send(options.foreign_key)
      model_c = options.model_class
      res = model_c.where(options.primary_key => foreign_key).first
    end

    assoc_options[options.class_name.underscore.to_sym] = options
  end

  def has_many(name, options = {})

    options = HasManyOptions.new(name, self.to_s, options)

    define_method name do
      primary_key = self.send(options.primary_key)
      model_c = options.model_class
      res = model_c.where(options.foreign_key => primary_key)
    end

  end

  def assoc_options
    @assoc_options ||= {}
  end
end
