# TODO: split in multiple files

$ ->

  # render

  render_block_cursor = (data) ->
    html = block_cursor_template data
    $(".block_cursor").html       html  if $(".block_cursor").length > 0
    $(".block_cursor_view").html  html  if $(".block_cursor_view").length > 0
    $(".prev_arrow").hide()
    bind_cursor_prev_next_buttons()

  render_block_view = (block) ->
    html = block_template block
    $(".block_txs").html html
    $(".hash").html block.hash.replace /^0+/, ''
    $(".block_number").html block.num

  render_block_not_found_view = () ->
    html = block_not_found_template()
    $(".block_txs").html html


  #  actions

  load_transactions = (block_num) ->
    console.log("load_transactions #{block_num}")
    request = $.get "/api/blocks/"+block_num, (data) ->
      max_txs_num = 16
      # console.log "got block", data
      block = data.block
      block.num = block_num
      block.tx_count = block.tx.length
      block.size = s.numberFormat block.size
      window.block_cache = _.clone block
      block.tx = block.tx[0..max_txs_num]
      render_block_view block
      many_txes = window.block_cache.tx.length > max_txs_num
      if many_txes
        $(".load_more").show()
      else
        $(".load_more").hide()

    request.fail ->
      render_block_not_found_view()

  load_latest_block = (block_num) ->
    $.getJSON "/api/blocks_latest_num", (data) ->
      block_num = data.block_num
      load_transactions block_num

  switch_view_to_block_cursor = ->
    $(".block_timeline").hide()


  # globals

  window.block_cache = {}

  window.onpopstate = (evt) ->
    state = evt.state
    block_num = state.block_num if state
    unless block_num
      load_latest_block()
    else
      load_transactions block_num


  # view - action bindings

  bind_cursor_prev_next_buttons = ->
    $(".block_prev").on "click", (evt) ->
      window.block_curr = window.block_curr-1
      $(".block_curr").html(window.block_curr)
      load_transactions window.block_curr
      history.pushState({ block_num: window.block_curr }, "Block ##{window.block_curr}", "/blocks/#{window.block_curr}")

    $(".block_next").on "click", (evt) ->
      window.block_curr = window.block_curr+1
      $(".block_curr").html(window.block_curr)
      load_transactions window.block_curr
      history.pushState({ block_num: window.block_curr }, "Block ##{window.block_curr}", "/blocks/#{window.block_curr}")

    # TODO: delete
    # $(".block_prev, .block_next").on "click", (evt) =>
    #   elem = evt.currentTarget
    #   if elem.dataset.blockCount
    #     document.location = elem.dataset.url

  bind_main_elements = () ->
    $(".prev_arrow").on "click", (evt) ->
      curr = window.block_curr
      prev = curr - 1
      load_transactions prev
      window.block_curr = prev
      data = { block_prev: prev, block_curr: curr, block_next: curr+1 }
      render_block_cursor data
      switch_view_to_block_cursor()

    $(".load_more").on "click", (evt) ->
      elem = evt.currentTarget
      $(elem).hide()
      render_block_view window.block_cache

    $(".block_btn").on "click", (evt) ->
      elem = evt.currentTarget
      block_count = elem.dataset.blockCount
      block_num = block_count
      load_transactions block_num
      history.pushState({ block_num: block_num }, "Block ##{block_num}", "/blocks/#{block_num}")

  # pages

  # page - blocks

  if $(".page.blocks").length > 0
    # TODO: change name from .block_template to .block_info
    block_template = $(".block_template").html()
    block_template = Handlebars.compile(block_template)

    block_not_found_template = $(".block_not_found_template").html()
    block_not_found_template = Handlebars.compile(block_not_found_template)

    block_cursor_template = $(".block_cursor_template").html()
    block_cursor_template = Handlebars.compile(block_cursor_template)

    load_transactions window.block_curr

    bind_cursor_prev_next_buttons()
    bind_main_elements()
