require 'rubypress'
require 'mime/types'

module WordpressUtility
  class Post

    def initialize(params)
      @wp = Rubypress::Client.new(host: params[:host],
                                  username: params[:user],
                                  password: params[:password],
                                  path: params[:path])
    end

    def create_post(params)
      @wp.newPost( content: {
                       post_status: 'draft',
                       post_date: Time.now,
                       post_content: params[:content].squish,
                       post_title: 'PDF TO POST'
                   }
      )
    end

    def edit_post(params)
      @wp.editPost( post_id: params[:id],
                    content: {
                        post_content: "#{params[:content]} #{params[:images].join("\n")}" #"This is the body <img src='#{@image['url']}'></img>",
                    }
      )
    end

    def upload_image(filename)
      @image = @wp.uploadFile(data: {name: File.basename(filename),
                                        type: MIME::Types.type_for(filename).first.to_s,
                                        bits: XMLRPC::Base64.new(File.open(filename).read)
      })
    end

    def delete_post(params)
      @wp.newPost( post_id: params[:post_id])
    end

  end
end