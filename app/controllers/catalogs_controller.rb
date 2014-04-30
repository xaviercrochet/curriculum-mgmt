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
		@catalog = Catalog.create(catalog_params)
		@catalog.parse
		redirect_to @catalog

	end

	def show
		@catalog = Catalog.find(params[:id])
		# File.open(Rails.root.join('', '',  'app/assets/javascripts/coucou.json'),  "w+") do |f|
		# 	f.write(@catalog.to_json)
		# end

	end

	def upload
		@catalog = Catalog.find(params[:catalog_id])
		if ! params[:catalog].nil?
			@catalog.update(catalog_params)
			# @catalog.upload_spreadsheet(params[:catalog])
			@catalog.parse_ss
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
			params.require(:catalog).permit(:faculty, :department, :graph, :spreadsheet)
		end
end
