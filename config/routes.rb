class SubdomainConstraint
  def self.matches?(request)
    request.subdomain.present? && request.subdomain != 'www'
  end
end
Rails.application.routes.draw do
  constraints SubdomainConstraint do
    resources :projects
  end
  resources :companies
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
