require_relative '../lib/db_connection'
require_relative '../lib/sql_object'
require_relative '../lib/controller_base'
require_relative '../lib/router'
require 'rack'

DBConnection.reset

class Human < SQLObject
  attr_reader

  has_many :cats, foreign_key: :owner_id

  self.table_name = 'humans'
  self.finalize!
end

class Cat < SQLObject
  attr_reader :name, :owner

  belongs_to :human, foreign_key: :owner_id

  self.table_name = 'cats'
  self.finalize!
end

class CatsController < ControllerBase
  def index
    render_content(Cat.all.to_s, "text/text")
  end
end

h = Human.new(fname: "John", lname: "Goddard", house_id: 1)
h.save
c1 = Cat.new(name: "Cato", owner_id: 5)
c2 = Cat.new(name: "Moto", owner_id: 5)

c1.save
c2.save

router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)

  res.finish
end

Rack::Server.start(
 app: app,
 Port: 3000
)
