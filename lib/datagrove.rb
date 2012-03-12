require 'datagrove/version'
require 'json'
require 'socket'

module DataGrove
  ROOT = "f5b5451c-5e7c-455c-b8f2-30d0ac982ca0"

  class Client
    def initialize(host="localhost", port=12346)
      @host = host
      @port = port
    end

    def load_by_id(tag_id=ROOT)
      req({
              op_code: 0,
              tag_id: tag_id
          })
    end

    def load_by_name(tag_name="root")
      load_by_id tag_name_to_id(tag_name)
    end

    def tag(name, description="")
      req({
              op_code: 2,
              name: name,
              desc: description
          })
    end

    def remove_by_id(tag_id)
      req({
              op_code: 3,
              tag_id: tag_id
          })
    end

    def remove_by_name(tag_name)
      remove_by_id tag_name_to_id(tag_name)
    end

    def unload
      req({
              op_code: 1
          })
    end

    def status
      req({op_code: 6})
    end

    def is_running?
      req({op_code: 6})["is_running"]
    end

    private

    def req(data)
      request = data.merge({ username: "default"}).to_json

      Socket.tcp(@host, @port) do |socket|
        socket.print(request)
        p json = socket.read
        JSON.parse(json)
      end
    end

    def tag_name_to_id(tag_name)
      tags = status()["server"]["tags"].select{|t| t["properties"]["name"] == tag_name}
      raise "Tag name not found" if tags.empty?

      tags.first["properties"]["id"]
    end
  end
end