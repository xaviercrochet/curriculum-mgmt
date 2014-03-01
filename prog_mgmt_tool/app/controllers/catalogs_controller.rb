class CatalogsController < ApplicationController

	def index
		@catalogs = Catalog.all
	end

	def new
		@catalog = Catalog.new
	end

	def create

		@catalog = Catalog.new(catalog_params)
		
		@catalog.filename = @catalog.faculty+'-'+@catalog.department+'-'+Time.now.to_formatted_s(:number)+'-catalog_seed.xgml' unless ! params[:catalog][:data]
		@catalog.save
		if params[:catalog][:data]
			uploaded_io = params[:catalog][:data]
			File.open(Rails.root.join('', 'seeds',
				@catalog.filename), 'wb') do |file|
				file.write(uploaded_io.read)
			end
			@catalog.parse
		end
		redirect_to @catalog

	end

	def show
		@catalog = Catalog.find(params[:id])
	end

	def destroy
		@catalog = Catalog.find(params[:id])
		@catalog.destroy
		redirect_to catalogs_path
	end

	private
		def catalog_params
			params.require(:catalog).permit(:faculty, :department)
		end
end
