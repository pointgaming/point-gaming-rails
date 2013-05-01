var PointGaming = PointGaming || {};

PointGaming.ToolbarController = function(options){
  options = options || {};
  this.toolbar_selector = options.toolbar_selector || 'header';
  this.search_field_selector = options.search_field_selector || 'input.search-query';

  this.registerHandlers();
};

PointGaming.ToolbarController.prototype.registerHandlers = function() {
  var self = this;

  $('form.navbar-search.search-form').submit(function(e){
    if ( $('input.search-query', this).val() === '') {
      e.preventDefault();
      return false;
    } else {
      return true;
    }
  });

  $(this.search_field_selector, this.toolbar_selector).typeahead({
    ajax: { url: '/search.json', triggerLength: 1, method: 'get', contentType: 'application/json', dataType: 'json' },
    display: 'name', 
    val: 'url',
    itemSelected: function(item, val, text){
      if (item.is('.category') || item.length === 0) {
        return false;
      } else if (item.data('type') === 'Game') {
        var link = $('a#search_typeahead_link_for_game');
        if (link.length === 0) {
          link = $('<a id="search_typeahead_link_for_game" />');
          link.appendTo($('body'));
        }

        link.attr('href', item.data('value'))
          .attr('data-action', 'joinLobby')
          .addClass('requires-desktop-client check-for-client')
          .click();

        $('input.search-query', 'form.navbar-search.search-form').val('');
      } else {
        window.location.href = val;
      }
    },
    select: function() {
      var $selectedItem = this.$menu.find('.active');
      if ($selectedItem.is('.category')) {
        this.$element.val('').change();
        return;
      }

      this.$element.val($selectedItem.text()).change();
      this.options.itemSelected($selectedItem, $selectedItem.attr('data-value'), $selectedItem.text());
      return this.hide();
    },
    prev: function (event) {
        var active = this.$menu.find('.active').removeClass('active');
        var prev = active.prev();

        if (prev.is('.category')) {
          prev = prev.prev();
        }

        if (!prev.length) {
            prev = this.$menu.find('li').last();
        }

        prev.addClass('active');
    },
    next: function (event) {
        var active = this.$menu.find('.active').removeClass('active');
        var next = active.next();

        if (next.is('.category')) {
          next = next.next();
        }

        if (!next.length) {
            next = $(this.$menu.find('li:not(.category)')[0]);
        }

        next.addClass('active');
    },
    mouseenter: function (e) {
        this.$menu.find('.active').removeClass('active');
        $(e.currentTarget).not('.category').addClass('active');
    },
    // We will create a custom render function so that we can group the results by type
    render: function (items) {
      var that = this;

      items = $(items).map(function (i, item) {
        i = $(that.options.item).attr('data-value', item[that.options.val])
                                .attr('data-type', item['type']);
        i.find('a').html(that.highlighter(item[that.options.display], item));
        return i[0];
      });

      items.first().addClass('active');

      this.$menu.html(categorizeItems(items));
      return this;
    }
  });
};

var categorizeItems = function(arr) {
  var categorized_items = {},
      group_iter = function(index, item) {
          item = $(item);
          var type = item.data('type');
          
          if (typeof(categorized_items[type]) === 'undefined') {
              categorized_items[type] = [];
          }

          categorized_items[type].push(item);
      },
      convert = function(category_name, items) {
          var category = $('<li class="category"><span>' + category_name + '</span></li>');
          items.unshift(category);
          return items;
      },
      key,
      results = [];

  arr.each(group_iter);

  for (key in categorized_items) {
    if (categorized_items.hasOwnProperty(key)) {
      Array.prototype.push.apply(results, convert(key, categorized_items[key]));
    }
  }

  return results;
};
