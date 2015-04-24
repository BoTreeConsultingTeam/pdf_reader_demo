Rails.application.routes.draw do
  #get 'pdf_converter/new'
  post 'convert' => 'pdf_converter#convert'
  get 'images/:filename' => 'pdf_converter#image', as: 'image'
  root 'pdf_converter#new'
end
