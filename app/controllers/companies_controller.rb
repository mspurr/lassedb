class CompaniesController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :new, :update, :destroy, :create]
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :price, :fetch_data, only: [:show]
  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.all
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'Company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def fetch_data
      require 'zip'
      require 'open-uri'

      cc = Company.find(params[:id])

      cases = []
      url = "https://clinicaltrials.gov/ct2/download_studies?cond=&term=&type=&rslt=&age_v=&gndr=&intr=&titles=&outc=&spons=" + cc.apiTitle + "&spons_ex=Y&lead=&id=&cntry=&state=&city=&dist=&locn=&strd_s=&strd_e="
      content = open(url)

      Zip::File.open_buffer(content) do |zipfile|
        zipfile.each do |file|
          #data = File.read(file)

          doc = Nokogiri::XML(file.get_input_stream.read)

          trial = { 'brief_title' => doc.at_css('brief_title').text,
                    'nct_id' => doc.at_css('nct_id').text,
                    'official_title' => doc.at_css('official_title').text,
                    'agency' => doc.at_css('agency').text,
                    'brief_summary' => doc.css('brief_summary textblock').text,
                    'detailed_description' => doc.css('detailed_description textblock').text,
                    'overall_status' => doc.css('overall_status').text,
                    'start_date' => doc.css('start_date').text,
                    'completion_date' => doc.css('completion_date').text,
                    'primary_completion_date' => doc.css('primary_completion_date').text,
                    'phase' => doc.css('phase').text,
                    'study_type' => doc.css('study_type').text,
                    'intervention_name' => doc.css('intervention intervention_name').text
                    }

          cases.append(trial)
        end
      end

      @trials = cases

    end



    def price
      @company = Company.find(params[:id])


      # check if google ticker is defined
      if @company.GTicker.to_s.strip.empty?

        #collect the current stockprice of a company not on google finance
        url = "https://query1.finance.yahoo.com/v7/finance/chart/" + @company.yticker + "?range=1d&interval=1m&indicators=quote&includeTimestamps=true"
        price = Faraday.get url
        price = price.body
        price = JSON.parse price
        price = price['chart']['result']
        prevClose = price[0]['meta']['previousClose']
        @lastUpdated = Time.at(price[0]['meta']['currentTradingPeriod']['post']['end']).strftime("20%y-%m-%d %H:%M")
        currPrice = price[0]['indicators']['quote'][0]['close']
        currTime = price[0]['timestamp']

        n=0
        @stockPrice = []
        @stockTime = []
        while n < currPrice.length
          if currPrice[n] == nil
          else
            @stockPrice.append(currPrice[n])
            @stockTime.append(currTime[n])
          end
          n=n+1
        end
        @stockPrice = @stockPrice[-1]
        @currTime = Time.at(@stockTime[-1]).strftime("20%y-%m-%d %H:%M")
        @change = ((@stockPrice-prevClose)/(@stockPrice)*100).round(3)
        @changeP = @stockPrice-prevClose




        time = Date.today.to_time.to_i
        time2 = time - 157680000

        #url = "https://query1.finance.yahoo.com/v7/finance/chart/" + @company.yticker + "?period1=" + time2.to_s + "&period2=" + time.to_s + "&interval=1d&indicators=quote&includeTimestamps=true"
        url = "https://query1.finance.yahoo.com/v7/finance/chart/" + @company.yticker + "?range=5y&interval=1d&indicators=quote&includeTimestamps=true"
        @stock = Faraday.get url
        @stock = @stock.body
        @stock = JSON.parse @stock
        @stock = @stock['chart']['result']
        stamps = @stock[0]['timestamp']
        openv = @stock[0]['indicators']['quote'][0]['open']
        close = @stock[0]['indicators']['quote'][0]['close']
        high = @stock[0]['indicators']['quote'][0]['high']
        low = @stock[0]['indicators']['quote'][0]['low']





        @data2 = []
        n = 0
        while n < stamps.length
          list = [stamps[n], (openv[n]), (high[n]), (low[n]), (close[n])]
          @data2.append(list)
          n = n+1
        end


        n=0
        @data3 = []
        while n < @data2.length
          if @data2[n].include?(nil)
          else
            @data3.append(@data2[n])
          end
          n = n + 1
        end

        n = 0
        while n < @data3.length
          @data3[n][0] = Time.at(@data3[n][0]).strftime("20%y-%m-%d")
          n = n+1
        end

        n = 0
        a = "["
        while n < @data3.length do
          h = "{\"date\": \"" + (@data3[n][0]).to_s + "\", \"open\": \"" + (@data3[n][1]).round(3).to_s + "\", \"high\": \"" + (@data3[n][2]).round(3).to_s + "\", \"low\": \"" + (@data3[n][3]).round(3).to_s + "\", \"close\": \"" + (@data3[n][4]).round(3).to_s + "\"}"
          a = a + h + ", "
          n = n+1
        end
        @a = a[0..-3] + "]"

      else
        url = 'http://finance.google.com/finance/info?client=ig&q=' + @company.exch + '%3A' + @company.GTicker
        @stock = Faraday.get url
        @stock = @stock.body
        @stock = @stock.lines[1..-1].join
        @stock = @stock.split.join(' ')[2..-1]
        @stock = JSON.parse @stock
        @stock = @stock[0]
        # data from google as csv for charts
        url = 'https://www.google.com/finance/getprices?q=' + @company.GTicker + '&x=' + @company.exch + '&i=86400&p=40Y&f=d,c,v,k,o,h,l&df=cpct&auto=0&ei=Ef6XUYDfCqSTiAKEMg'
        @data = Faraday.get url
        @data = @data.body

        @data = @data.lines[7..-1].join
        @data = @data.split("\n")
        @date = (@data[0][0..9]).to_i

        @data2 = @data
        @data3 = []
        n = 0
        x = 0
        set = []

        while n < @data2.length
          d = @data2[x].split(',')
          if d.length < 2
            set.append(@data2[0..x])
            @data2 = @data2[x+1..-1]
            x=0
            n=0
          else
            @data3.append(d)
            x = x+1
            n = n + 1
          end
          #@data2[x][0] = x*86400 + @date
        end


        n = 0
        x = 0
        curr_d = 0
        while n < @data3.length
          if @data3[n][0].length == 11
            @data3[n][0] = @data3[n][0][1..-1]
            curr_d = @data3[n][0].to_i
            @data3[n][0] = @data3[n][0].to_i
          else
            @data3[n][0] = @data3[n][0].to_i*86400 + curr_d
          end
          @data3[n][0] = Time.at(@data3[n][0]).strftime("20%y-%m-%d")
          n = n+1
        end

        n = 0
        a = "["
        while n < @data3.length do
          h = "{\"date\": \""+ @data3[n][0] +"\", \"open\": \""+ @data3[n][4] +"\", \"high\": \""+ @data3[n][2] +"\", \"low\": \""+ @data3[n][3] +"\", \"close\": \""+ @data3[n][1] +"\"}"
          a = a + h + ", "
          n = n+1
        end
        @a = a[0..-3] + "]"

      end

      # Monthly change
      @month = "n/a"
      if @data3[-22]
        @month = ((@data3[-1][1]).to_f-(@data3[-22][1]).to_f)/((@data3[-22][1]).to_f)*100
      end

      #weekly change
      @week = "n/a"
      if @data3[-6]
        @week = ((@data3[-1][1]).to_f-(@data3[-6][1]).to_f)/((@data3[-6][1]).to_f)*100
      end

      #year change
      @year = "n/a"
      if @data3[-250]
        @year = ((@data3[-1][1]).to_f-(@data3[-250][1]).to_f)/((@data3[-250][1]).to_f)*100
      end

      #3year change
      @tyear = "n/a"
      if @data3[-250*3]
        @tyear = ((@data3[-1][1]).to_f-(@data3[-250*3][1]).to_f)/((@data3[-250*3][1]).to_f)*100
      end

      #3year change
      @fyear = "n/a"
      if @data3[-250*5]
        @fyear = ((@data3[-1][1]).to_f-(@data3[-250*5][1]).to_f)/((@data3[-250*5][1]).to_f)*100
      end

      #year to date
      @dyear = "n/a"
      now = @data3[-1][0][5..6].to_i
      if @data3[-now*21+1]
        @dyear = ((@data3[-1][1]).to_f-(@data3[-now*21+1][1]).to_f)/((@data3[-now*21+1][1]).to_f)*100
      end
    end

    def set_company
      @company = Company.find(params[:id])
      @focus_areas = @company.focus.split(', ')
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:title, :description, :focus, :logo, :ticker, :GTicker, :exch, :yticker, :apiTitle)
    end
end
