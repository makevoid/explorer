# TODO: extract coffee

$ ->

  load_latest_block = (block_num) ->
    $.getJSON "/api/blocks_latest_num", (data) ->
      block_num = data.block_num
      load_transactions block_num

  render_transactions = (block) ->
    html = tx_template block
    $(".transactions").html html
    $(".hash").html block.hash.replace /^0+/, ''
    $(".block_number").html block.num

  load_transactions = (block_num) ->
    console.log("load_transactions #{block_num}")
    $.getJSON "/api/blocks/"+block_num, (data) ->
      # console.log "got block", data
      block = data.block
      block.num = block_num
      block.tx_count = block.tx.length
      block.size = s.numberFormat block.size
      window.block_cache = _.clone block
      block.tx = block.tx[0..16]
      render_transactions block

  window.block_cache = {}

  window.onpopstate = (evt) ->
    state = evt.state
    block_num = state.block_num if state
    unless block_num
      load_latest_block()
    else
      load_transactions block_num

  if $(".page.blocks").length > 0
    # TODO: change name from .tx_template to .block_info
    tx_template = $(".tx_template").html()
    tx_template = Handlebars.compile(tx_template)

    load_transactions window.block_curr

    $(".load_more").on "click", (evt) ->
      elem = evt.target
      $(elem).hide()
      render_transactions window.block_cache

    $(".block_prev").on "click", (evt) ->
      window.block_curr = window.block_curr-1
      $(".block_curr").html(window.block_curr)
      load_transactions window.block_curr

    $(".block_next").on "click", (evt) ->
      window.block_curr = window.block_curr+1
      $(".block_curr").html(window.block_curr)
      load_transactions window.block_curr

    $(".block_btn").on "click", (evt) ->
      elem = evt.target
      block_count = elem.dataset.blockCount
      block_num = block_count
      load_transactions block_num
      history.pushState({ block_num: block_num }, "Block ##{block_num}", "/blocks/#{block_num}")
