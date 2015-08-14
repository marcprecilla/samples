# encoding: UTF-8
class Program < ActiveRecord::Base
	include UUIDRecord
	attr_accessible :description, :name, :uuid
end
