(function() {
  var Force, init, restart;

  Force = (function() {
    function Force(svg, width, height) {
      this.svg = svg;
      this.width = width != null ? width : window.innerWidth;
      this.height = height != null ? height : window.innerHeight;
      this._force = d3.layout.force().size([this.width, this.height / 2]).nodes([
        {
          x: this.width / 2,
          y: this.height,
          fixed: true
        }
      ]).linkDistance(20).charge(-300).on('tick', (function(_this) {
        return function() {
          return _this.tick();
        };
      })(this));
    }

    Force.prototype.tick = function() {
      this.svg.selectAll('.link').attr('x1', function(d) {
        return d.source.x;
      }).attr('y1', function(d) {
        return d.source.y;
      }).attr('x2', function(d) {
        return d.target.x;
      }).attr('y2', function(d) {
        return d.target.y;
      });
      return this.svg.selectAll('.node').attr('cx', function(d) {
        return d.x;
      }).attr('cy', function(d) {
        return d.y;
      });
    };

    Force.prototype.nodes = function() {
      return this._force.nodes();
    };

    Force.prototype.links = function() {
      return this._force.links();
    };

    Force.prototype.node = function() {
      return this.svg.selectAll('.node').data(this.nodes());
    };

    Force.prototype.link = function() {
      return this.svg.selectAll('.link').data(this.links());
    };

    Force.prototype.start = function() {
      return this._force.start();
    };

    Force.prototype.drag = function() {
      return this._force.drag;
    };

    Force.prototype.size = function(w, h) {
      return this._force.size([w, h]);
    };

    return Force;

  })();

  restart = function(force) {
    var link, node;
    link = force.link();
    link.enter().insert('line', '.node').attr('class', 'link');
    node = force.node();
    node.enter().insert('circle', '.cursor').attr('class', 'node').attr('r', 5).call(force.drag());
    return force.start();
  };

  init = function() {
    var force, height, svg, width;
    width = 960;
    height = 500;
    svg = d3.select('body').append('svg').attr('width', width).attr('height', height).on('mousedown', function() {
      var links, node, nodes, point;
      point = d3.mouse(this);
      node = {
        x: point[0],
        y: point[1]
      };
      nodes = force.nodes();
      links = force.links();
      nodes.push(node);
      nodes.forEach(function(target) {
        var x, y;
        x = target.x - node.x;
        y = target.y - node.y;
        if (Math.sqrt(x * x + y * y) < 10) {
          return links.push({
            source: node,
            target: target
          });
        }
      });
      return restart(force);
    });
    force = new Force(svg, width, height);
    restart(force);
    return window.force = force;
  };

  init();

}).call(this);
