Rails.application.routes.draw do
  #get 'pdf_converter/new'
  post 'publish' => 'pdf_converter#publish'
  get 'images/:filename' => 'pdf_converter#image', as: 'image'
  root 'pdf_converter#new'
end
