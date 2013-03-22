var PointGaming = PointGaming || {};

PointGaming.ToolbarController = function(options){
  options = options || {};
  this.toolbar_selector = options.toolbar_selector || 'header';
  this.search_field_selector = options.search_field_selector || 'input.search-query';

  this.registerHandlers();
};

PointGaming.ToolbarController.prototype.registerHandlers = function() {
  var self = this;

  $(this.search_field_selector, this.toolbar_selector).typeahead({
    ajax: { url: '/search.json', triggerLength: 1, method: 'get', contentType: 'application/json', dataType: 'json' },
    display: 'name', 
    val: 'url',
    itemSelected: function(item, val, text){
      if (item.is('.category')) {
        return false;
      }
      window.location.href = val;
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

        if (!prev.length && active.parent().parent().is('.category')) {
          var prevCategory = active.parent().parent().prev();
          if (prevCategory.length) {
            prev = prevCategory.find('li').last();
          }
        }

        if (!prev.length) {
            prev = this.$menu.find('li').last();
        }

        prev.addClass('active');
    },
    next: function (event) {
        var active = this.$menu.find('.active').removeClass('active');
        var next = active.next();

        if (!next.length && active.parent().parent().is('.category')) {
          var nextCategory = active.parent().parent().next();
          if (nextCategory.length) {
            next = nextCategory.find('li').first();
          }
        }

        if (!next.length) {
            next = $(this.$menu.find('li:not(.category)')[0]);
        }

        next.addClass('active');
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
          var category = $('<li class="category"><span>' + category_name + '</span><ul class="children"></ul></li>');
          category.find('ul.children').html(items);
          return category;
      },
      key,
      results = [];

  arr.each(group_iter);

  for (key in categorized_items) {
    if (categorized_items.hasOwnProperty(key)) {
      results.push(convert(key, categorized_items[key]));
    }
  }

  return results;
};
