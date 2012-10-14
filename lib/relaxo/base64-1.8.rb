
require 'base64'

module Base64
	def self.strict_encode64(data)
		encode64(data).gsub(/\s/, '')
	end
end