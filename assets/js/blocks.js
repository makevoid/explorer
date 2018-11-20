(function() {
  $(function() {
    var load_latest_block, load_transactions, render_transactions, tx_template;
    load_latest_block = function(block_num) {
      return $.getJSON("/api/blocks_latest_num", function(data) {
        block_num = data.block_num;
        return load_transactions(block_num);
      });
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
        var block;
        block = data.block;
        block.num = block_num;
        block.tx_count = block.tx.length;
        block.size = s.numberFormat(block.size);
        window.block_cache = _.clone(block);
        block.tx = block.tx.slice(0, 17);
        return render_transactions(block);
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
      load_transactions(window.block_curr);
      $(".load_more").on("click", function(evt) {
        var elem;
        elem = evt.target;
        $(elem).hide();
        return render_transactions(window.block_cache);
      });
      $(".block_prev").on("click", function(evt) {
        window.block_curr = window.block_curr - 1;
        $(".block_curr").html(window.block_curr);
        return load_transactions(window.block_curr);
      });
      $(".block_next").on("click", function(evt) {
        window.block_curr = window.block_curr + 1;
        $(".block_curr").html(window.block_curr);
        return load_transactions(window.block_curr);
      });
      return $(".block_btn").on("click", function(evt) {
        var block_count, block_num, elem;
        elem = evt.target;
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
