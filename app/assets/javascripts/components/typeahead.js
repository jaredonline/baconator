(function(root, undefined) {
  "use strict";
  Ember.TypeAheadComponent = Ember.TextField.extend({

    didInsertElement: function() {
      this._super();
      var _this = this;

      if(!this.get("data")){
        throw "No data property set";
      }

      if (jQuery.isFunction(this.get("data").then)){
        this.get("data").then(function(data) {
          _this.initializeTypeahead(data);
        });
      }

      else{
        this.initializeTypeahead(this.get("data"));
      }

    },

    initializeTypeahead: function(data){
      var _this = this;

      // constructs the suggestion engine
      var objects = new Bloodhound({
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        // `states` is an array of state names defined in "The Basics"
        local: $.map(data, function(object) { return {
          value: object.get(_this.get("name")),
          emberObject: object,
          name: object.get(_this.get("name"))
        };
       })
      });

      objects.initialize();

      this.typeahead = this.$().typeahead({
        hint: true,
        highlight: true,
        limit: this.get("limit") || 5,
      },
      {
        name: _this.$().attr('id') || "typeahead",
        source: objects.ttAdapter()
      });

      this.typeahead.on("typeahead:selected", function(event, item) {
        _this.set("selection", item.emberObject);
      });

      this.typeahead.on("typeahead:autocompleted", function(event, item) {
        _this.set("selection", item.emberObject);
      });

      if (this.get("selection")) {
        this.typeahead.val(this.get("selection.name"));
      }
    },

    selectionObserver: function() {
      if (Ember.isEmpty(this.get('selection')) === true) {
        return this.typeahead.val('');
      }
      return this.typeahead.val(this.get("selection").get(this.get("name")));
    }.observes("selection")

  });
  Ember.Handlebars.helper('type-ahead', Ember.TypeAheadComponent);
}(this));

