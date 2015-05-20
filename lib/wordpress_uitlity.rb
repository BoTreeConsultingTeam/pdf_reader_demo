require 'rubypress'
require 'mime/types'

module WordpressUtility
  class Post

    def initialize(params)
      @wordpress_client = Rubypress::Client.new( host: params[:host],
                                                username: params[:user],
                                                password: params[:password],
                                                path: params[:path] )
    end

    def create_post(params)
      @wordpress_client.newPost( content: {
                                           post_status: 'draft',
                                           post_date: Time.now,
                                           post_content: params[:content].squish,
                                           post_title: params[:title]
                                          }
                               )
    end

    def edit_post(params)
      @wordpress_client.editPost( post_id: params[:id],
                                  content: {
                                            post_content: "#{params[:content]} #{params[:images].join("\n")}"
                                           }
                                )
    end

    def upload_image(filename)
      @image = @wordpress_client.uploadFile(data: { name: File.basename(filename),
                                                    type: MIME::Types.type_for(filename).first.to_s,
                                                    bits: XMLRPC::Base64.new(File.open(filename).read)
                                                  }
                                            )
    end

  end
end