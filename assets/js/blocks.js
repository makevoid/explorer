(function() {
  $(function() {
    var bind_cursor_prev_next_buttons, block_cursor_template, load_latest_block, load_transactions, render_block_cursor, render_transactions, switch_view_to_block_cursor, tx_template;
    load_latest_block = function(block_num) {
      return $.getJSON("/api/blocks_latest_num", function(data) {
        block_num = data.block_num;
        return load_transactions(block_num);
      });
    };
    switch_view_to_block_cursor = function() {
      return $(".block_timeline").hide();
    };
    render_block_cursor = function(data) {
      var html;
      html = block_cursor_template(data);
      if ($(".block_cursor").length > 0) {
        $(".block_cursor").html(html);
      }
      if ($(".block_cursor_view").length > 0) {
        $(".block_cursor_view").html(html);
      }
      $(".prev_arrow").hide();
      return bind_cursor_prev_next_buttons();
    };
    render_transactions = function(block) {
      var html;
      html = tx_template(block);
      $(".transactions").html(html);
      $(".hash").html(block.hash.replace(/^0+/, ''));
      return $(".block_number").html(block.num);
    };
    load_transactions = function(block_num) {
      console.log("load_transactions " + block_num);
      return $.getJSON("/api/blocks/" + block_num, function(data) {
        var block, many_txes, max_txs_num;
        max_txs_num = 16;
        block = data.block;
        block.num = block_num;
        block.tx_count = block.tx.length;
        block.size = s.numberFormat(block.size);
        window.block_cache = _.clone(block);
        block.tx = block.tx.slice(0, +max_txs_num + 1 || 9e9);
        render_transactions(block);
        many_txes = window.block_cache.tx.length > max_txs_num;
        if (many_txes) {
          return $(".load_more").show();
        } else {
          return $(".load_more").hide();
        }
      });
    };
    window.block_cache = {};
    window.onpopstate = function(evt) {
      var block_num, state;
      state = evt.state;
      if (state) {
        block_num = state.block_num;
      }
      if (!block_num) {
        return load_latest_block();
      } else {
        return load_transactions(block_num);
      }
    };
    if ($(".page.blocks").length > 0) {
      tx_template = $(".tx_template").html();
      tx_template = Handlebars.compile(tx_template);
      block_cursor_template = $(".block_cursor_template").html();
      block_cursor_template = Handlebars.compile(block_cursor_template);
      load_transactions(window.block_curr);
      bind_cursor_prev_next_buttons = function() {
        $(".block_prev").on("click", function(evt) {
          window.block_curr = window.block_curr - 1;
          $(".block_curr").html(window.block_curr);
          load_transactions(window.block_curr);
          return history.pushState({
            block_num: window.block_curr
          }, "Block #" + window.block_curr, "/blocks/" + window.block_curr);
        });
        return $(".block_next").on("click", function(evt) {
          window.block_curr = window.block_curr + 1;
          $(".block_curr").html(window.block_curr);
          load_transactions(window.block_curr);
          return history.pushState({
            block_num: window.block_curr
          }, "Block #" + window.block_curr, "/blocks/" + window.block_curr);
        });
      };
      bind_cursor_prev_next_buttons();
      $(".prev_arrow").on("click", function(evt) {
        var curr, data, prev;
        curr = window.block_curr;
        prev = curr - 1;
        load_transactions(prev);
        window.block_curr = prev;
        data = {
          block_prev: prev,
          block_curr: curr,
          block_next: curr + 1
        };
        render_block_cursor(data);
        return switch_view_to_block_cursor();
      });
      $(".load_more").on("click", function(evt) {
        var elem;
        elem = evt.currentTarget;
        $(elem).hide();
        return render_transactions(window.block_cache);
      });
      return $(".block_btn").on("click", function(evt) {
        var block_count, block_num, elem;
        elem = evt.currentTarget;
        block_count = elem.dataset.blockCount;
        block_num = block_count;
        load_transactions(block_num);
        return history.pushState({
          block_num: block_num
        }, "Block #" + block_num, "/blocks/" + block_num);
      });
    }
  });

}).call(this);
