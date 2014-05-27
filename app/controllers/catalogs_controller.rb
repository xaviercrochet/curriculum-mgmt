class CatalogsController < ApplicationController
	before_action :authenticate_user!
	load_and_authorize_resource

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

	def upgrade
		@catalog = Catalog.find(params[:catalog_id])
		@catalog.upgrade_version
		redirect_to @catalog

	end

	def show
		@catalog = Catalog.includes(:academic_year).find(params[:id])
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
			flash[:notice] = "Votre fichier excel a été correctement importé"
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
			params.require(:catalog).permit(:name, :academic_year_id, :graph, :spreadsheet)
		end
end
