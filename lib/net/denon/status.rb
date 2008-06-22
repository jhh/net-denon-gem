module Net
  module Denon
    class Status

      attr_reader :standby, :mute, :master_volume, :master_max_volume, :channel_volume,
                  :input_source, :main_zone, :record_source
    
      def initialize
        @channel_volume = Hash.new
      end

      def standby?
        @standby
      end

      def on?
        ! @standby
      end

      def mute?
        @mute
      end
    
      def main_zone_on?
        @main_zone
      end

      def update(response)
        response.each("\r") do |r|
          case command(r)
          when "PW"
            update_power(r)
          when "MV"
            update_master_volume(r)
          when "CV"
            update_channel_volume(r)
          when "MU"
            update_mute(r)
          when "SI"
            update_input_source(r)
          when "ZM"
            update_main_zone(r)
          when "SR"
            update_record_source(r)
          end
        end
      end

      private

      def update_power(r)
        @standby = (parameter(r) == "STANDBY")
      end

      def update_master_volume(r)
        p = parameter(r)
        if p.length == 2 then
          @master_volume = p.to_i
        else
          @master_max_volume = p[-2..-1].to_i
        end
      end

      def update_channel_volume(r)
        re = /^([A-Z]+) (\d\d)$/
        md = re.match(parameter(r))
        vol = md[2].to_i
        case (md[1])
        when "FL"
          @channel_volume[:front_left] = vol
        when "FR"
          @channel_volume[:front_right] = vol
        when "C"
          @channel_volume[:center] = vol
        when "SW"
          @channel_volume[:subwoofer] = vol
        when "SL"
          @channel_volume[:surround_left] = vol
        when "SR"
          @channel_volume[:surround_right] = vol
        when "SBL"
          @channel_volume[:surround_back_left] = vol
        when "SBR"
          @channel_volume[:surround_back_right] = vol
        when "SB"
          @channel_volume[:surround_back] = vol
        end
      end

      def update_mute(r)
        @mute = (parameter(r) == "ON")
      end

      def update_input_source(r)
          @input_source = parameter(r)
      end
    
      def update_main_zone(r)
        @main_zone = (parameter(r) == "ON")
      end
    
      def update_record_source(r)
          @record_source = parameter(r)
      end
    
      def command(r)
        r[0, 2]
      end

      def parameter(r)
        r[2, r.length-3]
      end

      def to_s
       string = ''
       string += "standby: #{@standby}\n" 
       string += "mute: #{@mute}\n"
       string += "master volume: #{@master_volume}\n"
       string += "master max volume: #{@master_max_volume}\n"
       string += "input source: #{@input_source}\n"
       string += "main zone: #{@main_zone}\n"
       string += "record source: #{record_source}\n"
      end
    end
  end
end