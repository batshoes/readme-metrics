require 'socket'
require 'securerandom'

def validate_uuid(uuid)
  return if uuid.nil?

  uuid.match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}$/i)
end

module Readme
  class Payload
    attr_reader :ignore

    def initialize(har, info, ip_address, development:)
      Readme::Metrics.logger.warn "Payload Class Initialize Begin"
      @har = har
      @user_info = info.slice(:id, :label, :email)
      @user_info[:id] = info[:api_key] unless info[:api_key].nil? # swap api_key for id if api_key is present
      @log_id = info[:log_id]
      @ignore = info[:ignore]
      @ip_address = ip_address
      @development = development
      @uuid = SecureRandom.uuid
      Readme::Metrics.logger.warn "Payload Class Initialized"
    end

    def to_json(*_args)
      Readme::Metrics.logger.warn "to_json Initialized"
      Readme::Metrics.logger.warn "Validated _id: #{_id: validate_uuid(@log_id) ? @log_id : @uuid}"
      Readme::Metrics.logger.warn "Validated group: #{group: @user_info}"
      Readme::Metrics.logger.warn "Validated clientIPAddress: #{clientIPAddress: @ip_address}"
      Readme::Metrics.logger.warn "Validated development: #{development: @development}"
      Readme::Metrics.logger.warn "Validated request: #{: JSON.parse(@har.to_json)}"
      json = {
        _id: validate_uuid(@log_id) ? @log_id : @uuid,
        group: @user_info,
        clientIPAddress: @ip_address,
        development: @development,
        request: JSON.parse(@har.to_json)
      }.to_json
      Readme::Metrics.logger.warn "successfully parsed JSON"
      json
    end
  end
end
