class CatalogsController < ApplicationController
	before_action :authenticate_user!
	
	def index
		@catalogs = Catalog.all
	end

	def new
		@catalog = Catalog.new
	end

	def create
		@catalog = Catalog.create(catalog_params)
		if @catalog.errors.any?
			render action: :new
		else	
			@catalog.parse
			redirect_to @catalog
		end
	end

	def show
		@catalog = Catalog.find(params[:id])
		p @catalog.id.to_s
		# File.open(Rails.root.join('', '',  'app/assets/javascripts/coucou.json'),  "w+") do |f|
		# 	f.write(@catalog.to_json)
		# end

	end

	def upload
		@catalog = Catalog.find(params[:catalog_id])
		if ! params[:catalog].nil?
			@catalog.update(catalog_params)
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
