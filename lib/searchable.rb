require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    where_string = params.map{|k, v| "#{k} = ?"}.join(" AND ")
    res = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_string}
    SQL

    res.map{|row| self.new(row)}
  end
end

class SQLObject
  extend Searchable
end
