require 'rubypress'
require 'mime/types'

module WordpressUtility
  class Post
    FILENAME = 'cherry_PNG635.png'

    def initialize
      @wp = Rubypress::Client.new(host: "104.131.111.55",
                                  username: "demo",
                                  password: "demo",
                                  path: "http://104.131.111.55/xmlrpc.php")
    end

    def create_post(params)
      @wp.newPost( blog_id: 1, # 0 unless using WP Multi-Site, then use the blog id
                   content: {
                       post_status: 'draft',
                       post_date: Time.now,
                       post_content: params[:content].squish,
                       post_title: 'PDF TO POST',
                       post_author: 1, # 1 if there is only the admin user, otherwise the user's id

                   }
      )
    end

    def edit_post(params)
      @wp.editPost( blog_id: 1, post_id: params[:id], author_id: 1, # 0 unless using WP Multi-Site, then use the blog id
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
      @wp.newPost( blog_id: params[:blog_id], post_id: params[:post_id])
    end

  end
end