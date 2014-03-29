(function() {
  var Tree, force, height, init, initX, width;

  Tree = (function() {
    function Tree(elem, width, height) {
      this.elem = elem;
      this.width = width;
      this.height = height;
      this._force = d3.layout.force().size([this.width * 2, this.height * 2 / 4]).nodes([
        {
          x: this.width,
          y: this.height,
          fixed: true
        }
      ]).linkDistance(20).linkStrength(0.5).charge(this.height / -20).on('tick', (function(_this) {
        return function() {
          return _this.tick();
        };
      })(this));
      this.restart();
    }

    Tree.prototype.restart = function() {
      var link, node;
      link = this.link().data(this.links());
      link.enter().insert('line', '.node').attr('class', 'link');
      node = this.node().data(this.nodes());
      node.enter().insert('g', '.cursor').attr('class', 'node').each(function(d) {
        var el, size;
        el = d3.select(this);
        if (d.last === true && Math.random() < .1) {
          size = 6;
          return el.append('rect').attr({
            'width': size,
            'height': size,
            'x': size / -2,
            'y': size / -2
          });
        } else {
          return el.append('circle').attr('r', 1);
        }
      });
      return this.start();
    };

    Tree.prototype.createBranch = function(onComplete) {
      var arr, count, iid, max, target;
      count = 0;
      arr = [];
      max = 4;
      iid = setInterval((function(_this) {
        return function() {
          var amount, dat, index, nodes, _i, _j, _len, _results;
          if (++count <= max) {
            amount = 1;
            for (index = _i = 1; 1 <= count ? _i <= count : _i >= count; index = 1 <= count ? ++_i : --_i) {
              amount *= index;
            }
            nodes = _this.nodes();
            arr = [];
            nodes.forEach(function(node, index) {
              var num, _j, _ref, _results;
              if (index >= nodes.length - amount) {
                _results = [];
                for (num = _j = 0, _ref = Math.min(8, amount); 0 <= _ref ? _j <= _ref : _j >= _ref; num = 0 <= _ref ? ++_j : --_j) {
                  _results.push(arr.push([
                    {
                      x: node.x + (num - amount / 2) * 10,
                      y: node.y,
                      last: count === max
                    }, nodes[index]
                  ]));
                }
                return _results;
              }
            });
            _results = [];
            for (_j = 0, _len = arr.length; _j < _len; _j++) {
              dat = arr[_j];
              _results.push(_this.add(dat[0], dat[1]));
            }
            return _results;
          } else {
            clearInterval(iid);
            if (onComplete) {
              return onComplete();
            }
          }
        };
      })(this), 400);
      target = this.nodes()[0];
      return this.add({
        x: this.width,
        y: target.y - 20
      }, target);
    };

    Tree.prototype.wind = function(ran) {
      var nodes;
      if (ran == null) {
        ran = 20;
      }
      nodes = this.nodes();
      nodes.forEach(function(node) {
        return node.x += Math.random() * ran;
      });
      return this.restart();
    };

    Tree.prototype.add = function(node, target) {
      var links, nodes, x, y;
      nodes = this.nodes();
      links = this.links();
      nodes.push(node);
      if (target) {
        x = target.x - node.x;
        y = target.y - node.y;
        links.push({
          source: node,
          target: target
        });
      }
      return this.restart();
    };

    Tree.prototype.tick = function() {
      this.link().attr('x1', function(d) {
        return d.source.x;
      }).attr('y1', function(d) {
        return d.source.y;
      }).attr('x2', function(d) {
        return d.target.x;
      }).attr('y2', function(d) {
        return d.target.y;
      });
      return this.node().attr('transform', function(d) {
        return 'translate(' + d.x + ',' + d.y + ')';
      });
    };

    Tree.prototype.nodes = function() {
      return this._force.nodes();
    };

    Tree.prototype.links = function() {
      return this._force.links();
    };

    Tree.prototype.node = function() {
      return this.elem.selectAll('.node');
    };

    Tree.prototype.link = function() {
      return this.elem.selectAll('.link');
    };

    Tree.prototype.start = function() {
      return this._force.start();
    };

    Tree.prototype.stop = function() {
      return this._force.stop();
    };

    return Tree;

  })();

  this.Tree = Tree;

  width = window.innerWidth;

  height = window.innerHeight;

  initX = 200;

  force = void 0;

  init = function() {
    var group, svg, tree;
    svg = d3.select('body').append('svg').attr('width', width).attr('height', height);
    group = svg.append('g');
    tree = new Tree(group, initX, height);
    return tree.createBranch(function() {
      var count, end, iid;
      count = 0;
      end = 30;
      return iid = setInterval(function() {
        if (Math.random() < .2) {
          tree.wind();
        }
        if (++count > end) {
          tree.wind(40);
          clearInterval(iid);
          return group.transition().duration(2000).attr('transform', 'translate(0,0)').each('end', function() {
            return tree.stop();
          });
        }
      }, 100);
    });
  };

  init();

}).call(this);
