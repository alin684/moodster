require 'net/http'

class User < ApplicationRecord
  validates :name, uniqueness: true, presence: true
  validates :password, presence: true
	has_many :features

  has_secure_password

  def self.get_emotion_hash(sesh)
    # NOTE: You must use the same region in your REST call as you used to obtain your subscription keys.
    #   For example, if you obtained your subscription keys from westcentralus, replace "westus" in the
    #   URL below with "westcentralus".
    uri = URI('https://westcentralus.api.cognitive.microsoft.com/face/v1.0/detect')
    uri.query = URI.encode_www_form({
			'returnFaceAttributes' => 'age,gender,emotion,makeup,glasses,facialHair,accessories'
    })
    request = Net::HTTP::Post.new(uri.request_uri)
    # Request headers
    request['Content-Type'] = 'application/octet-stream'
    # NOTE: Replace the "Ocp-Apim-Subscription-Key" value with a valid subscription key.
    request['Ocp-Apim-Subscription-Key'] = 'efab7f5dd06a4f5cbb80374da9e9ef79'
    # Request body
    @user = User.find(sesh)
    data = File.read("./app/assets/images/#{@user.id}/#{@user.features.length+1}.jpg")
    request.body = data
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
    end
    return response.body
  end

end
