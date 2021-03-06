class ProfileInformation::FetchInfo

  def get_data(name, profile, company, driver)
    @name = name
    @profile = profile
    @company  = company
    @driver = driver
    login
  end

  def login
    @driver.navigate.to("https://www.linkedin.com/login")
    puts "[INFO]: Entering username"
    @driver.find_element(:name, "session_key").send_keys("kushal@ausavi.com")
    puts "[INFO]: Entering password"
    @driver.find_element(:name, "session_password").send_keys("Punjab2017@")
    # @driver.find_element(:name, "session_key").send_keys("rachitverma.001@gmail.com")
    # puts "[INFO]: Entering password"
    # @driver.find_element(:name, "session_password").send_keys("gmail8871338693")
    puts "[INFO]: Logging in"

    @driver.find_element(:xpath, "//button").click
    # sleep(3)

    wait = Selenium::WebDriver::Wait.new(:timout => 10)
    wait.until {@driver.find_element(:css, "body.ember-application")}

    company_data
  end

  def company_data
    puts "[INFO]: Navigating to profile #{@profile}"

    @driver.navigate.to(@profile)
    wait = Selenium::WebDriver::Wait.new(:timout => 10)
    wait.until {@driver.find_element(:css, "div.organization-outlet")}
    puts "[INFO]: Scraping data"

    sleep(4)
    doc = Nokogiri::HTML(@driver.page_source)


    name = doc.css("h1 span[dir=ltr]")
    name = name ? name.text : nil
    p "b name=#{name}"

    tagline = doc.css("p.org-top-card-summary__tagline")
    p "b tagline1=#{tagline}"
    tagline = tagline ? tagline&.text&.strip : nil
    p "b tagline2=#{tagline}"

    description = doc.css("div.org-top-card-summary-info-list__info-item")
    p "b desc1=#{description}"

    description_content = description ? description&.text&.split("\n")[1]&.strip : nil
    p "b desc2=#{description}"

    city = description ? description&.text&.split("\n")[3]&.strip : nil
    p "b city=#{city}"

    followers = description ? description&.text&.split("\n")[5]&.strip : nil
    p "followers=#{followers}"
    # no_of_employees = doc.css("span.org-top-card-secondary-content__see-all")
    # //span[@class='t-20 t-black t-bold']

    no_of_employees = doc.css("span.t-20")
    p "b employees1=#{no_of_employees}"

    no_of_employees = no_of_employees ? no_of_employees&.text&.strip : nil
    p "b employees2=#{no_of_employees}"


    logo = doc.css("div.org-top-card-primary-content__logo-container img")&.first ? doc.css("div.org-top-card-primary-content__logo-container img")&.first["src"] : nil
    p "b logo=#{logo}"

    @count = 0

    # founders = []
    # founders << get_founders('ceo')
    # founders << get_founders('coo')
    # founders <<  get_founders('cto')


    employers_data= get_employee_data

    payload = {
      name: @name,
      tagline: tagline,
      description: description_content,
      city: city,
      followers: followers,
      no_of_employees: no_of_employees,
      logo: logo,
      # founders_count: founders&.count
      # url: @profile
    }
    @company.update!(payload)

    puts "[DONE]:"
    sleep(2)
    @driver.quit
    employees = @company.employee_details
    {
      company_detail:@company,
      founder_details: employees.where(role_id:Role.find_by(name:"Founder").id),
      employee_details: employees.where(role_id:Role.find_by(name:"Employee").id)
    }
  end

  def get_founders(post)

    p "inside founders"

    @driver.navigate.to("#{@profile}/?keywords=#{post}")
    sleep(4)


    source  = @driver.page_source
    doc = Nokogiri::HTML(source)


    names = []
    check=[]
    i = 0
    j=0

    if doc.css(:xpath,"//span[@class='t-20 t-black t-bold']").text.strip.first.to_i>=1

      loop do
        a = names

        names = doc.css("div.org-people-profile-card__profile-title")&.text.split("\n")&.reject(&:blank?)&.collect(&:strip)

        p "names = #{names}"

        if a.count == names.count
          break
        else
          i=i+1
          @driver.execute_script("window.scrollTo(0, document.body.scrollHeight)")
          sleep(4)
          source = @driver.page_source
          doc = Nokogiri::HTML(source)
        end

      end
    # end

    # if doc.css(:xpath,"//span[@class='t-20 t-black t-bold']").text.strip.first.to_i>=1
    #   p "navigated founders"
    #   #
    #   doc.css('ul.display-flex').each do |founder|
    #     designation = founder.css("div.lt-line-clamp--multi-line")&.text&.strip
    #     p "designation = #{designation}"
    #     if designation.present?
    #       name=founder.css("div.org-people-profile-card__profile-title")&.text&.strip
    #       p "name=#{name}"
    #
    #       names << name
    #     end
    #   end

      p "================================="

      names&.reject(&:blank?)&.each do |name|

        p "inside name = #{name}"

        @driver.navigate.to("#{@profile}/?keywords=#{post}")
        sleep(4)
        # binding.pry
        @driver.find_element(:xpath,"//div[@class='org-people-profile-card__profile-title t-black lt-line-clamp lt-line-clamp--single-line ember-view'][contains(.,'#{name.split(" ")[0]}')]")&.click

        sleep(4)

        wait = Selenium::WebDriver::Wait.new(:timout => 10)
        wait.until {@driver.find_element(:css, "div.text-body-medium")}

        source = @driver.page_source

        doc = Nokogiri::HTML(source)

        city = doc.css(:xpath,"//span[@class='text-body-small inline t-black--light break-words']")&.text&.strip

        p "city = #{city}"

        description = doc.css(:xpath, "//div[@class='text-body-medium break-words']")&.text&.strip

        p "description = #{description}"

        designation = description
        p "designation = #{designation}"

        image = doc.css(:xpath,"//img[@width='200']")&.first ? doc.css(:xpath,"//img[@width='200']")&.first['src'] : nil
        p "image = #{image}"

        @driver.find_element(:xpath, "//a[contains(.,'Contact info')]")&.click

        sleep(2)

        source = @driver.page_source

        doc = Nokogiri::HTML(source)

        mobile = doc.css(:xpath,"//span[@class='t-14 t-black t-normal']")&.text&.strip

        p "mobile = #{mobile}"

        email =  doc.css(:xpath,"//a[@class='pv-contact-info__contact-link link-without-visited-state t-14']")&.text&.split[1] || "#{name&.split[0]&.downcase}.#{name&.split[1]&.downcase}@#{@company&.name&.parameterize&.underscore}.in" || nil


        p "email=#{email}"

        payload = {
          first_name: name&.split()[0],
          last_name: name&.split()[1],
          city: city,
          # description: description,
          email:email,
          mobile_no:mobile,
          designation: designation,
          image: image,
          role_id:Role.find_by(name:'Founder').id
        }

        p "payoad = #{payload}"

        detail = @company.employee_details.where(first_name:payload[:first_name], last_name:payload[:last_name], email:payload[:email]).first

        unless detail.present?
          @company.employee_details.create!(payload)
        else
          detail.update(payload)
        end

        @driver.navigate.to("#{@profile}/?keywords=#{post}")

        sleep(2)
        source = @driver.page_source
        doc = Nokogiri::HTML(source)
      end
    end
    names
  end

  def get_employee_data
    p "inside empoyees"

    @driver.navigate.to("#{@profile}")
    sleep(4)
    source = @driver.page_source
    doc = Nokogiri::HTML(source)
    p "navigated employees"
    names = []
    check=[]
    i = 0
    j=0
    blank_names = 0

    loop do
      a = names

      names = doc.css("div.org-people-profile-card__profile-title")&.text.split("\n")&.reject(&:blank?)&.collect(&:strip)

      p "names = #{names}"

      if names.blank?

        @driver.execute_script("window.scrollTo(0, document.body.scrollHeight)")
        blank_names = blank_names + 1

        sleep(4)
        source = @driver.page_source
        doc = Nokogiri::HTML(source)

        break if blank_names >=25
      else

        if a.count == names.count
          # binding.pry
          break
        else
          i=i+1
          @driver.execute_script("window.scrollTo(0, document.body.scrollHeight)")
          sleep(4)
          source = @driver.page_source
          # binding.pry
          doc = Nokogiri::HTML(source)
        end
      end
    end

        # binding.pry
    p "================================="
    names&.reject(&:blank?)&.each do |name|
      p "inside name = #{name}"

      @driver.find_element(:xpath,"(//input[contains(@type,'text')])[2]").send_keys(name)
      sleep(2)
      @driver.find_element(:xpath,"(//input[contains(@type,'text')])[2]").send_keys("\n")
      sleep(3)
      source = @driver.page_source
      doc = Nokogiri::HTML(source)
      sleep(4)



      unless doc.css(:xpath,"//span[@class='t-20 t-black t-bold']").text.strip.first.to_i>=1
        @driver.navigate.to("#{@profile}")
        sleep(2)
        first_name = name.split.first
        @driver.find_element(:xpath,"(//input[contains(@type,'text')])[2]").send_keys(first_name)
        sleep(2)
        @driver.find_element(:xpath,"(//input[contains(@type,'text')])[2]").send_keys("\n")
        sleep(3)
        source = @driver.page_source
        doc = Nokogiri::HTML(source)
        sleep(4)
      end

      @driver.find_element(:xpath,"//div[@class='org-people-profile-card__profile-title t-black lt-line-clamp lt-line-clamp--single-line ember-view'][contains(.,'#{name.split(" ")[0]}')]")&.click

      sleep(4)

      wait = Selenium::WebDriver::Wait.new(:timout => 10)
      wait.until {@driver.find_element(:css, "div.text-body-medium")}

      source = @driver.page_source

      doc = Nokogiri::HTML(source)

      city = doc.css(:xpath,"//span[@class='text-body-small inline t-black--light break-words']")&.text&.strip

      p "city = #{city}"
      description = doc.css(:xpath, "//div[@class='text-body-medium break-words']")&.text&.strip
      p "description = #{description}"

      designation = description
      p "designation = #{designation}"

      image = doc.css(:xpath,"//img[@width='200']")&.first['src']
      p "image = #{image}"

      @driver.find_element(:xpath, "//a[contains(.,'Contact info')]")&.click
      sleep(2)

      source = @driver.page_source
      doc = Nokogiri::HTML(source)

      mobile = doc.css(:xpath,"//span[@class='t-14 t-black t-normal']")&.text&.strip
      p "mobile = #{mobile}"

      email =  doc.css(:xpath,"//a[@class='pv-contact-info__contact-link link-without-visited-state t-14']")&.text&.split[1] || "#{name&.split[0]&.downcase}.#{name&.split[1]&.downcase}@#{@company&.name&.parameterize&.underscore}.in"

      p "email=#{email}"
      payload = {
        first_name: name&.split()[0],
        last_name: name&.split()[1],
        city: city,
        # description: description,
        email:email,
        mobile_no:mobile,
        designation: designation,
        image: image,
        role_id:Role.find_by(name:'Employee').id
      }

      p "payoad = #{payload}"

      detail = @company.employee_details.where(first_name:payload[:first_name], last_name:payload[:last_name], email:payload[:email]).first
      p "Detail = #{detail}"
      p "employee_name = #{payload[:first_name]}"

      @company.employee_details.create!(payload) unless detail.present?

      p "company_name = #{@company.name}"
      @driver.navigate.to("#{@profile}")

      sleep(2)
      source = @driver.page_source
      doc = Nokogiri::HTML(source)
      p "Navigated After Company"
      sleep(3)
    end
    names
  end

end