  require 'watir-webdriver'
  require 'headless'

  def self.scan_videobull(titles, proxy)
    begin

      pid = Process.fork do
        system 'export DISPLAY=:99 && Xvfb :99 -ac'
      end

      url_array = Array.new
      headless = Headless.new
      headless.start
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile.proxy = Selenium::WebDriver::Proxy.new :http => proxy + ':8080', :ssl => proxy + ':8080'
      titles.each do |title|
        b = Watir::Browser.new :firefox, :profile => profile
        b.goto 'http://videobull.com/?s=' << title

        @i = 0
        b.links.each do |link|
        begin
          if find_matches(title, link.title)
            @title = link.title
            if @i > 1
              c = Watir::Browser.new :firefox, :profile => profile
              c.goto(link.href)
              c.links.each do |link2|
                if find_matches('external.php', link2.href) && link2.text == 'Play Now'
                  begin
                    u = URI.parse(link2.href)
                    p = CGI.parse(u.query)

                    d = Watir::Browser.new :firefox, :profile => profile
                    d.goto(link2.href)
                    sleep 8
                    d.link(:id =>"skip_button").fire_event "onclick"

                    case p['linkfrom']
                   
	              when 'putlocker.com'
                        d.frames.each do |frame|
                          frame.frames.each do |frame2|
                            url_array.push [@title, strip_http(frame2.src)]
                          end
                        end

                      else
                        puts d.link.href
                        url_array.push [@title, strip_http(d.link.href)]

                    end
                    d.close
                  rescue => err
                    log_error("A File locker link failed")
                    log_error(err)
                  end
                end
              end
              c.close
            end
            @i += 1
          end
        rescue => err
          log_error("file locker episode page failed")
          log_error(err)
        end
      end
        b.close
      end
      headless.destroy
      Process.kill("SIGKILL", pid)
      return url_array
    rescue => err
      headless.destroy
      Process.kill("SIGKILL", pid)
      log_error("scan_videobull failed")
      log_error(err)
      return nil
    end
  end

  def self.run_all_file_lockers(titles)
    results = Array.new
    proxy = create_proxy(rand(1..65535),66,1776228,1,1)
    results.push scan_videobull(titles, proxy)
    delete_proxy(proxy)
    return results.compact!
  end
