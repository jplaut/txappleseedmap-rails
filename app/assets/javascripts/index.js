var Map = function() {};

Map.prototype.TILE_LAYER = L.tileLayer("https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png", {
  maxZoom: 19,
  attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="https://cartodb.com/attributions">CartoDB</a>'
});

Map.prototype.GROUPS = {
  black_or_african_american: "African American students",
  asian: "Asian students",
  hispanic_latino: "Latino students",
  american_indian_or_alaska_nat: "Native American students",
  special_education: "Special Education students",
  two_or_more_races: "Students of two or More Races",
  white: "White students",
  // native_hawaiian_other_pacific:
  //"economic_disadvantage"
];

Map.prototype.PUNISHMENT_TYPES = {
  "Expulsion": { label: "expulsion actions", code: "Expulsion" },
  "AltEdu": { label: "alternative placements", code: "AltEdu" },
  "OSS": { label: "out-of-school suspensions", code: "OSS" },
  "ISS": { label: "in-school suspensions", code: "ISS" }
};

Map.prototype.GROUP_PERCENT_CODES = [
  "DPETBLAP", // black
  "DPETASIP", // asian?
  "DPETHISP", // latino?
  "DPETINDP", // native american?
  "DPETSPEP", // special ed?
  "DPETTWOP", // multi-ethnic?
  "DPETWHIP", // white?
];

// Default Stripes.
Map.prototype.STRIPE_PATTERN = new L.StripePattern({
  weight: 1,
  spaceWeight: .5,
  color: '#b3b3b3',
  angle: 45
});

Map.prototype.DEFAULT_PUNISHMENT_TYPE = 'OSS'
Map.prototype.DEFAULT_YEAR = "2016"
Map.prototype.DEFAULT_ETHNICITY = "black_or_african_american"

Map.prototype.init = function(containerDivId, mapDivId) {
  this.$el = $( "#" + containerDivId );
  this.data = {}
  this.punishmentType = this.DEFAULT_PUNISHMENT_TYPE
  this.year = this.DEFAULT_YEAR
  this.ethnicity = this.DEFAULT_ETHNICITY

  this.population = 0;

  this.map = new L.Map(mapDivId, {
    center: [31.50, -98.41], // Johnson City
    zoom: 7
  });

  this.addListeners()
  this.createMap()
}

Map.prototype.addListeners = function() {
  var self = this
  this.$el.find(".selector__button").on("click", this.handleDataToggleClick.bind(this));
  $(".student_characteristic_selector").on("change", this.handleDataToggleClick.bind(this));

  // Attach event handler to drop-down menu to update data after
  // selection changed.
  $("#dropdown").on("change", function(event) {
    // Get the selection from the drop-down menu
    var key = event.currentTarget.value;
    console.log("In dropdown " + key);
    // Load the data from the corresponding file
    $('.selector__title').text(this.PUNISHMENT_TYPES[key].label)
    self.fetchStatistics(key).then(function(stats) {

    });
  })
}

Map.prototype.createMap = function() {
  var self = this,
    mapObject = this.mapObject,
    options = this.getOptions();
    // Adds tileLayer from the Map Class to the mapObject
    this.STRIPE_PATTERN.addTo(mapObject); //adding pattern definition to mapObject
    this.TILE_LAYER.addTo(mapObject);
    //this.requestInitialData(options);
    this.loadDistrictLayer(function(data) {
      var districtLayer = L.geoJSON(data)
      districtLayer.addTo(self.mapObject)
      self.createPopups(data, districtLayer)
    });
};

Map.prototype.createPopups = function() {

}


Map.prototype.getOptions = function() {
  debugger
  var self = this,
    sentenceCase = this.sentenceCase,
    stripes = this.stripes,
    fischerValue = this.dataSet + "_scale_" + this.groups[this.population],
    punishmentPercentValue = "percent_" + this.dataSet + "_" + this.groups[this.population],
    percentStudentsValue = "percent_students_" + this.groups[this.population],
    groupNameInPopup = this.groupDisplayName[this.population],
    displayvalue = this.displaypunishment[this.dataSet],
    schoolYear = this.schoolYear;

  return {
    style: function(feature) {
      var value = (feature.properties[fischerValue]);
      var dname = feature.properties.district_name;
      if (value == null) {
        return {
          fillColor: self.getFillColor(Number(feature.properties[fischerValue])),
          fillPattern: stripes,
          weight: 1,
          opacity: 1,
          color: '#b3b3b3',
          fillOpacity: 0.6
        }
      } else {
        return {
          fillColor: self.getFillColor(Number(feature.properties[fischerValue])),
          weight: 1,
          opacity: 1,
          color: '#b3b3b3',
          fillOpacity: 0.6
        };
      }
    },
    //popup information for each district
    onEachFeature: function onEachFeature(feature, layer) {
      var percentStudentsByGroup = (Number(feature.properties[percentStudentsValue])) * 100,
        districtName = feature.properties.district_name,
        groupName = groupNameInPopup,
        punishmentPercent = (Number(feature.properties[punishmentPercentValue])) * 100,
        //punishmentsCount = (Number(feature.properties[punishmentCountValue])) || 0,
        punishmentType = displayvalue,
        popupContent;

      if (!isNaN(parseFloat((feature.properties[fischerValue])))) {
        popupContent = [
          "<span class='popup-text'>",
          "In <b>" + districtName + "</b>, ",
          groupName + " received " + Math.round(punishmentPercent * 100) / 100.0 + "% of " + punishmentType + " and represent ", +Math.round(percentStudentsByGroup * 100) / 100.0 + "% of the student population ",
          "</span>"
        ].join('');
      } else if (percentStudentsByGroup == 0) {
        popupContent = "<span class='popup-text'>" + districtName + " reported that it had no " + groupName + " for the <b>" + schoolYear + "</b> school year.</span>";
      } else {
        popupContent = "<span class='popup-text'>Data not available in <b>" + districtName + "</b> for this student group.</span>";
      }
      if (feature.properties) layer.bindPopup(popupContent);
    }
  };

  // remove existing layer for previous group
  thiz.clearGeojsonLayer.call(thiz);

  thiz.addDataToMap(dataLayer, thiz.mapObject, options)
};
//sets population when user clicks choice
Map.prototype.handleDataToggleClick = function(e) {
  //remove active button style
  $(".selector__button").removeClass("selector__button--active");
  console.log("Me me me");
  this.population = typeof $(this).data("group-id") === 'number' ? $(this).data("group-id") : $(e.target).val();
  var options = this.getOptions();
  //console.log(thiz);
  // change toggle button CSS to indicate "active"
  $(e.currentTarget).addClass("selector__button--active");
  // remove existing layer for previous group

  thiz.fetchStatistics(thiz.population, )
};

Map.prototype.fetchStatistics = function(year, ethnicity, action, cb) {
  var cacheKey = this.cacheKey(year, ethnicity, action)

  if (this.stats[cacheKey]) {
    return cb(this.stats[cacheKey])
  } else {
    return $.ajax({
      dataType: "json",
      url: '/api/v1/statistics?ethnicity_name=' + ethnicity + '&year=' + year '&action_type=' + action,
      context: this,
      success: function(data) {
        this.stats[cacheKey] = data
        cb(data)
      },
      error: function(err) {
        console.log("ERROR:", err)
      }
    });
  }
}

Map.prototype.cacheKey = function(year, ethnicity, action) {
  return year + ':' + ethnicity + ':' + action
}

// Loads data from GeoJSON file and adds layer to map
Map.prototype.loadDistrictLayer = function(cb) {
  return $.ajax({
    dataType: "json",
    url: '/api/v1/districts',
    context: this,
    success: callback
  });
};

// Update data after selection is made
Map.prototype.selectData = function(dataKey) {
  /*
   Takes a key for a data layer and loads the data
   from the corresponding GeoJSON file.
   */

  var thiz = this
  this.dataSet = dataKey;
  /*if(typeof dataKey !== 'undefined'){
      console.log(dataKey + " in clearGeojsonLayer");
  } else {
      console.log("dataKey is undefined here in clearGeojsonLayer")
  }*/
  // Add new layer
  debugger
  this.fetchStatistics(thiz.population, dataKey, function(data) {
    thiz.addDataToMap(data)
  });
};

Map.prototype.addDataToMap = function(data) {
  debugger


  //console.log(data);  //.objects.simple_oss.geometries.properties.district_name);
  //for (var n = 0; n < data.objects.simple_oss.geometries.length; n++) {
  //var dName = data.objects.simple_oss.geometries[n].properties.district_name;
  //if (dName)
  //districtNames.push(dName);
  //districtBounds[dName] = L.polygon(data.objects.simple_oss.geometries[n].geometry.coordinates).getBounds();
  //}



  // autocomplete searchbox stuff
  $("#searchbox").autocomplete({
    source: districtNames,
    select: function(event, ui) {
      if (ui.item) {
        $('#searchbox').val(ui.item.value);
      }
      var hiStyle = {
        weight: 5,
        color: '#ceda6a',
        opacity: 1
      };
      var layer = layers[ui.item.value];
      thiz.clearHighlight();
      thiz.hilight_layer = layer;
      layer.setStyle(hiStyle);
      map.fitBounds(layer.getBounds());
    }
  });

};

Map.prototype.clearHighlight = function() {
  if (this.hilight_layer != null) {
    this.dataLayer.resetStyle(this.hilight_layer);
  }
};

Map.prototype.getFillColor = function(d) {
  var red = ['#fee5d9', '#fcbba1', '#fc9272', '#fb6a4a', '#de2d26', '#a50f15'],
    purple = ['#f2f0f7', '#dadaeb', '#bcbddc', '#9e9ac8', '#756bb1', '#54278f'],
    gray = '#DEDCDC';


  //return d == false   ? gray    :
  return d < -0.99999 ? purple[5] :
    d < -0.9984 ? purple[4] :
    d < -0.992 ? purple[3] :
    d < -0.96 ? purple[2] :
    d < -0.8 ? purple[1] :
    d < -0.2 ? purple[0] :
    d <= 0 ? 'white' :
    // d == 0      ? 'white' :
    d < 0.2 ? 'white' :
    d < 0.8 ? red[0] :
    d < 0.96 ? red[1] :
    d < 0.992 ? red[2] :
    d < 0.9984 ? red[3] :
    d < 0.99999 ? red[4] :
    d <= 1 ? red[5] :
    gray;
};

$(function() {
  var map = new Map();
  map.init('leMap', 'map')
})
