class CatalogsController < ApplicationController

	def index
		@catalogs = Catalog.all
	end

	def new
		@catalog = Catalog.new
	end



	def download
		@catalog = Catalog.find(params[:catalog_id])
		@catalog.create_doc
		send_file @catalog.ss_filename, :type => 'application/vnd.ms-excel', :filename => @catalog.ss_filename
	end

	def create

		@catalog = Catalog.new(catalog_params)
		@catalog.filename = "seeds/"+params[:catalog][:faculty]+'-'+params[:catalog][:department]+'-'+Time.now.to_formatted_s(:number)+'-catalog_seed.xgml' unless params[:catalog][:data].nil?
		@catalog.save
		@catalog.upload(params[:catalog])
		redirect_to @catalog

	end

	def show
		@catalog = Catalog.find(params[:id])
		File.open(Rails.root.join('', '',  'app/assets/javascripts/coucou.json'),  "w+") do |f|
			f.write(@catalog.to_json)
		end

	end

	def upload
		@catalog = Catalog.find(params[:catalog_id])
		if ! params[:catalog].nil?
			@catalog.upload_spreadsheet(params[:catalog])
		end
		redirect_to @catalog
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
