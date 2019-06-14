module ViewHelpers

  def identicon(content, klass: "", size: nil)
    bg  = [255, 255, 255]
    icon_size = 30
    icon_size = size if size
    img = Identicon.data_url_for content, icon_size, bg
    haml_tag :img, src: img, class: "identicon #{klass}"
  end

  def qrcode_html(content, size=50)
    # for addresses this size is fine
    size = content.size < 40 ? 4 : 7
    qr = RQRCode::QRCode.new(content,
      size: size,
      level: :h,
      # resize_gte_to: false,
      # resize_exactly_to: false,
      fill: 'white',
      # color: 'black',
      # border_modules: 4,
      # module_px_size: 6,
      file: nil # path to write
    )
    qr.as_svg
  end

  def qrcode(content, size: 50, klass: nil)
    raise "Unsuitable for this application - lenght > 80 chars" if content.size > 80
    haml_concat qrcode_html content, size
  end

  def body_class
    request.path.split("/")[1]
  end

  def js_void
    "javascript:void(0)"
  end

  def table_row(text, colspan: 5)
    haml_tag(:tr) do
      haml_tag(:td, colspan: colspan) do
        haml_concat text
      end
    end
  end

  def content_for(key, &block)
    if block
      @content_for ||= {}
      @content_for[key] = yield
    else
      @content_for && @content_for[key]
    end
  end
  
end
