CurriculumMgmt::Application.routes.draw do
  get "landing_page/index"
  root "landing_page#index"
  devise_for :users, :path => 'accounts' 
  resources :justifications do
    resources :answers
  end
  resources :users do
    get :choose_catalog
    patch :update_catalog
    resources :student_programs, shallow: true do
      resources :validations
      resources :justifications do
        resources :answers
      end
      get :configure
      get :new_validation
      get :check
      resources :years, shallow: true do
        resources :semesters, shallow: true do
          resources :courses
        end
      end
    end
  end
  resources :validations do
    get :validate
  end
  

  resources :catalogs, shallow: true do
    get :upgrade
    patch :upload
    resources :courses
    resources :p_modules, shallow: true do
      resources :sub_modules
      resources :courses, shallow: true do
        resources :constraints
      end
    end
    resources :programs, shallow: true do
      resources :properties
      resources :courses
      resources :p_modules
    end
  end
end
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :justifications, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :justifications
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
