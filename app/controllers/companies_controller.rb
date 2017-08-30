class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
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
    def set_company
      @company = Company.find(params[:id])
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:title, :description, :focus, :logo, :ticker, :GTicker, :exch)
    end
end
