Rails.application.routes.draw do
  # Clearance routes
  resources :passwords, controller: "clearance/passwords", only: [ :create, :new ]
  resource :session, controller: "clearance/sessions", only: [ :create ]
  resources :users, controller: "users", only: [ :create ] do
    resource :password,
      controller: "clearance/passwords",
      only: [ :edit, :update ]
  end

  # Clearance route overrides
  get "/sign-in" => "clearance/sessions#new", as: :sign_in
  delete "/sign-out" => "clearance/sessions#destroy", as: :sign_out
  get "/sign-up" => "clearance/users#new", as: :sign_up

  # Dashboard pages
  namespace :dashboard do
    root to: "index#index", as: :root
    get "analytics", to: "analytics#index", as: :analytics
    get "posts", to: "posts#index", as: :posts
    get "support", to: "support#index", as: :support
    post "support", to: "support#create"
    get "channels", to: "channels#index", as: :channels

    # Settings page
    get "settings", to: "settings#edit", as: :settings
    patch "settings", to: "settings#update"

    # Posts routes
    resources :posts, only: [ :index, :show, :new, :create, :update ] do
      member do
        patch :publish
        patch :cancel
      end
    end
  end
  post "dashboard/send_get_started_text", to: "dashboard/index#send_get_started_text", as: :dashboard_send_get_started_text
  post "dashboard/send_verify_text", to: "dashboard/index#send_verify_text", as: :dashboard_send_verify_text
  post "dashboard/verify_phone_code", to: "dashboard/index#verify_phone_code", as: :dashboard_verify_phone_code
  post "dashboard/disconnect_facebook", to: "dashboard/channels#disconnect_facebook", as: :dashboard_disconnect_facebook
  post "dashboard/disconnect_instagram", to: "dashboard/channels#disconnect_instagram", as: :dashboard_disconnect_instagram
  post "dashboard/billing_portal", to: "dashboard/subscription#billing_portal", as: :billing_portal


  # Static pages
  get "privacy", to: "pages#privacy", as: :privacy
  get "terms", to: "pages#terms", as: :terms
  get "faq", to: "pages#faq", as: :faq
  get "blog", to: "pages#blog", as: :blog
  get "features", to: "pages#features", as: :features
  get "blog/:slug", to: "pages#blog_post", as: :blog_post

  # OmniAuth callback routes
  get "auth/google_oauth2/callback", to: "omniauth_callbacks#google_oauth2"
  get "auth/facebook/callback", to: "omniauth_callbacks#facebook"
  get "auth/instagram/callback", to: "omniauth_callbacks#instagram"
  get "auth/failure", to: "omniauth_callbacks#failure"

  # Root page
  root "main#index"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest.json" => "pwa#manifest", as: :pwa_manifest

  # images routes - URL shortener format: /images/[image_name].[extension]
  get "images/:id", to: "images#show", constraints: { id: /[^\/]+/ }

  # Sitemap route
  get "sitemap.xml", to: "application#sitemap"
  post "/webhooks/stripe", to: "webhooks#stripe"

  # Subscription routes
  get "dashboard/subscription", to: "dashboard/subscription#index", as: :dashboard_subscription
  post "dashboard/subscription/create_checkout_session", to: "dashboard/subscription#create_checkout_session", as: :create_checkout_session
end
