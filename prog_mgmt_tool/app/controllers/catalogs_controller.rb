class CatalogsController < ApplicationController

	def index
		@catalogs = Catalog.all
	end

	def new
		@catalog = Catalog.new
	end

	def create

		@catalog = Catalog.new(catalog_params)
		@catalog.filename = params[:catalog][:faculty]+'-'+params[:catalog][:department]+'-'+Time.now.to_formatted_s(:number)+'-catalog_seed.xgml' unless params[:catalog][:data].nil?
		@catalog.save
		@catalog.upload(params[:catalog])
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
