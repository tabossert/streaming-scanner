
  require 'digitalocean'

  Digitalocean.client_id  = "5db96853e00c384a68b3d51ac3ebee43"
  Digitalocean.api_key    = "ab3dd003049b32041494fce4137d1b8e"

  def self.delete_proxy(ipaddress)
    begin
      droplets = Digitalocean::Droplet.all
        droplets["droplets"].each do |drop|
          if drop["ip_address"] == ipaddress
            Digitalocean::Droplet.destroy(drop["id"])
          end
        end  
    rescue => err
      log_error("delete_proxy failed")
      log_error(err) 
    end     
  end

  def self.delete_all_proxies()
    begin
      droplets = Digitalocean::Droplet.all
        droplets["droplets"].each do |drop|
          if drop["name"].include? "proxy-"
            Digitalocean::Droplet.destroy(drop["id"])
          end
        end
    rescue => err
      log_error("delete_all_proxies failed")
      log_error(err)
    end
  end

  def self.create_proxy(name,size_id,image_id,region_id,howmany)
    begin
      status_array = Array.new
      ip_array = Array.new
      status = Digitalocean::Droplet.create({:name => "proxy-" + name.to_s, :size_id => size_id, :image_id => image_id, :region_id => region_id})
      puts status
      sleep 15
      ipaddress = Digitalocean::Droplet.retrieve(status.droplet.id).droplet.ip_address
      sleep 60 
      return ipaddress
    rescue => err
      log_error("create_proxy failed")
      log_error(err) 
    end     
  end

