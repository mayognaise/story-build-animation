(function() {
  var BaseView, CircleView, GroupView, PartsView, PathView, PolygonView, Tree, WalkingBird, WalkingBirdBack, WalkingBirdBody, WalkingBirdEye, WalkingBirdLeg, WalkingBirdLegs, WalkingBirdWing, WalkingBirdWings, downTime, init, loadSVG, openBirds, start, time, upTime, walkingBirdData, walkingBirdScale, walkingBirds, wingOrigin,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseView = (function() {
    function BaseView(parent, id, data) {
      this.parent = parent;
      this.id = id;
      this.data = data;
      this.width = window.innerWidth;
      this.height = window.innerHeight;
      if (!this.data) {
        if (this.id) {
          this.loadSVG();
        }
      } else {
        this.onLoadSVG();
      }
      window.onresize = (function(_this) {
        return function() {
          _this.width = window.innerWidth;
          _this.height = window.innerHeight;
          return _this.resize();
        };
      })(this);
    }

    BaseView.prototype.onLoadSVG = function() {
      return console.log(this.data);
    };

    BaseView.prototype.loadSVG = function() {
      return d3.xml("svg/" + this.id + ".svg", 'image/svg+xml', (function(_this) {
        return function(data) {
          _this.data = data;
          return _this.onLoadSVG();
        };
      })(this));
    };

    BaseView.prototype.resize = function() {
      return console.log(this.width, this.height);
    };

    return BaseView;

  })();

  PartsView = (function() {
    function PartsView(parent, data, id) {
      this.parent = parent;
      this.data = data;
      this.id = id;
    }

    PartsView.prototype.show = function() {
      this.elem().classed("hide", false);
      return this;
    };

    PartsView.prototype.hide = function() {
      this.elem().classed("hide", true);
      return this;
    };

    PartsView.prototype.remove = function() {
      return this.elem().remove();
    };

    PartsView.prototype.rotation = function() {
      if (this.origin) {
        return this.origin.deg;
      } else {
        return 0;
      }
    };

    PartsView.prototype.rotate = function(deg, sec) {
      if (sec == null) {
        sec = 0;
      }
      if (this.origin == null) {
        this.origin = {};
      }
      this.origin.deg = deg;
      this.elem().transition().duration(sec).attr('transform', this.transform(this.origin));
      return this;
    };

    PartsView.prototype.translate = function(dat, sec) {
      if (sec == null) {
        sec = 0;
      }
      if (dat) {
        if (this.origin == null) {
          this.origin = {};
        }
        this.origin = _.extend(this.origin, dat);
        this.elem().transition().duration(sec).attr('transform', this.transform(this.origin));
        return this;
      } else {
        if (this.origin) {
          return {
            x: this.origin.x,
            y: this.origin.y
          };
        } else {
          return {
            x: 0,
            y: 0
          };
        }
      }
    };

    PartsView.prototype.scale = function(scale, sec) {
      if (sec == null) {
        sec = 0;
      }
      if (this.origin == null) {
        this.origin = {};
      }
      this.origin.scale = scale;
      this.elem().transition().duration(sec).attr('transform', this.transform(this.origin));
      return this;
    };

    PartsView.prototype.elem = function(elem) {
      if (elem !== void 0) {
        this._elem = elem;
      }
      return this._elem;
    };

    PartsView.prototype.path = function() {
      var el;
      if (!this._path) {
        el = d3.select(this.data).select("#" + this.id);
        this._path = el.select(el[0][0].firstElementChild.nodeName);
      }
      return this._path;
    };

    PartsView.prototype.fill = function(hex) {
      if (hex !== void 0) {
        this._fill = hex;
      }
      if (!this._fill) {
        this._fill = this.path().attr('fill');
      }
      return this._fill;
    };

    PartsView.prototype.transform = function(dat) {
      return "translate(" + (dat.x || 0) + "," + (dat.y || 0) + ") rotate(" + (dat.deg || 0) + ") scale(" + (dat.scale !== void 0 ? dat.scale : 1) + ")";
    };

    return PartsView;

  })();

  PathView = (function(_super) {
    __extends(PathView, _super);

    function PathView(parent, data, id, origin) {
      var g, tgt;
      this.parent = parent;
      this.data = data;
      this.id = id;
      this.origin = origin;
      g = this.parent.append('g').attr('id', this.id);
      if (this.origin) {
        g.attr('transform', this.transform(this.origin));
        tgt = g.append('g').attr('transform', this.transform({
          x: this.origin.x * -1,
          y: this.origin.y * -1
        }));
      } else {
        tgt = g;
      }
      tgt.append('path').attr('fill', this.fill()).attr('d', this.d());
      this.elem(g);
    }

    PathView.prototype.changeD = function(d, sec) {
      if (sec == null) {
        sec = 0;
      }
      this.elem().select('path').transition().duration(sec).attr('d', d);
      return this;
    };

    PathView.prototype.d = function(d) {
      if (d !== void 0) {
        this._d = d;
      }
      if (!this._d) {
        this._d = this.path().attr('d');
      }
      return this._d;
    };

    return PathView;

  })(PartsView);

  CircleView = (function(_super) {
    __extends(CircleView, _super);

    function CircleView(parent, data, id, r, origin) {
      var g, tgt;
      this.parent = parent;
      this.data = data;
      this.id = id;
      this.r = r;
      this.origin = origin;
      g = this.parent.append('g').attr('id', this.id);
      if (this.origin) {
        g.attr('transform', this.transform(this.origin));
        tgt = g.append('g');
      } else {
        tgt = g;
      }
      this._circle = tgt.append('circle').attr('fill', this.fill()).attr('r', this.r);
      this.elem(g);
    }

    CircleView.prototype.circle = function() {
      return this._circle;
    };

    CircleView.prototype.circleScale = function(scale, sec) {
      if (sec == null) {
        sec = 0;
      }
      if (this.origin == null) {
        this.origin = {};
      }
      this.origin.scale = scale;
      this.circle().transition().duration(sec).attr('transform', this.transform({
        scale: scale
      }));
      return this;
    };

    return CircleView;

  })(PartsView);

  PolygonView = (function(_super) {
    __extends(PolygonView, _super);

    function PolygonView(parent, data, id, origin) {
      var g, tgt;
      this.parent = parent;
      this.data = data;
      this.id = id;
      this.origin = origin;
      g = this.parent.append('g').attr('id', this.id);
      if (this.origin) {
        g.attr('transform', this.transform(this.origin));
        tgt = g.append('g').attr('transform', this.transform({
          x: this.origin.x * -1,
          y: this.origin.y * -1
        }));
      } else {
        tgt = g;
      }
      this._polygon = tgt.append('polygon').attr('fill', this.fill()).attr('points', this.points());
      this.elem(g);
    }

    PolygonView.prototype.points = function(points) {
      if (points !== void 0) {
        this._points = points;
      }
      if (!this._points) {
        this._points = this.path().attr('points');
      }
      return this._points;
    };

    return PolygonView;

  })(PartsView);

  GroupView = (function(_super) {
    __extends(GroupView, _super);

    function GroupView(parent, id, origin) {
      var g, tgt;
      this.parent = parent;
      this.origin = origin;
      this.id("" + id + "_" + ((new Date).getTime()));
      g = this.parent.append('g').attr('id', this.id()).attr('class', id);
      if (this.origin) {
        g.attr('transform', this.transform(this.origin));
        tgt = g.append('g').attr('transform', this.transform({
          x: this.origin.x * -1,
          y: this.origin.y * -1
        }));
      } else {
        tgt = g;
      }
      this._target = tgt;
      this.elem(g);
    }

    GroupView.prototype.id = function(id) {
      if (id !== void 0) {
        this._id = id;
      }
      return this._id;
    };

    GroupView.prototype.target = function() {
      return this._target;
    };

    return GroupView;

  })(PartsView);

  time = 500;

  upTime = 400;

  downTime = 800;

  wingOrigin = {
    x: 253,
    y: 253
  };

  WalkingBird = (function(_super) {
    __extends(WalkingBird, _super);

    function WalkingBird(parent, id, width, height) {
      this.parent = parent;
      this.id = id;
      this.width = width;
      this.height = height;
      this.y = 0;
      this.group = new GroupView(this.parent, this.id, _.clone(wingOrigin));
      this.group.hide();
      this.elem = this.group.target();
      WalkingBird.__super__.constructor.call(this, this.parent, this.id, this.width, this.height);
    }

    WalkingBird.prototype.onLoadSVG = function() {
      this.back = new WalkingBirdBack(this.elem, this.data);
      this.legs = new WalkingBirdLegs(this.elem, this.data);
      this.body = new WalkingBirdBody(this.elem, this.data);
      this.wings = new WalkingBirdWings(this.elem, this.data);
      this.dot = new PathView(this.elem, this.data, 'dot');
      this.dot.hide();
      this.mouth = new PolygonView(this.elem, this.data, 'mouth');
      this.mouth.hide();
      this.eye = new WalkingBirdEye(this.elem, this.data);
      this.resize();
      return this.group.show();
    };

    WalkingBird.prototype.loop = function() {
      return this.open((function(_this) {
        return function() {
          _this.flyFlag = true;
          _this.fly();
          return setTimeout(function() {
            return _this.close(function() {});
          }, 6 * 1000);
        };
      })(this));
    };

    WalkingBird.prototype.resize = function(sec) {
      if (sec == null) {
        sec = 0;
      }
      this.group.translate({
        x: 0,
        y: this.y
      }, sec);
      return this;
    };

    WalkingBird.prototype.open = function(onComplete) {
      setTimeout((function(_this) {
        return function() {
          _this.dot.show();
          _this.wings.open();
          return setTimeout(function() {
            _this.wings.showBelow();
            return setTimeout(function() {
              _this.body.show();
              _this.eye.show();
              _this.legs.show();
              return setTimeout(function() {
                _this.back.show();
                _this.mouth.show();
                if (onComplete) {
                  return onComplete(_this);
                }
              }, time / 2);
            }, 100);
          }, time);
        };
      })(this), time);
      return this;
    };

    WalkingBird.prototype.close = function(onComplete) {
      this.fly(true);
      this.flyFlag = false;
      this.body.hide();
      this.eye.hide();
      this.mouth.hide();
      this.legs.hide();
      setTimeout((function(_this) {
        return function() {
          _this.back.hide();
          _this.wings.close();
          _this.dot.hide();
          if (onComplete) {
            return setTimeout(function() {
              return onComplete();
            }, time / 2);
          }
        };
      })(this), 100);
      return this;
    };

    WalkingBird.prototype.fly = function(up) {
      var duration;
      if (!this.flyFlag) {
        return;
      }
      if (up) {
        this.wings.up();
        this.body.up();
        this.legs.up();
        this.back.up();
        this.y = 0;
        up = false;
        duration = upTime;
      } else {
        this.wings.down();
        this.body.down();
        this.legs.down();
        this.back.down();
        this.y = 100;
        up = true;
        duration = downTime;
      }
      this.resize(duration);
      this.iid = setTimeout((function(_this) {
        return function() {
          if (_this.flyFlag) {
            return _this.fly(up);
          }
        };
      })(this), duration);
      return this;
    };

    return WalkingBird;

  })(BaseView);

  WalkingBirdBack = (function() {
    function WalkingBirdBack(elem, data) {
      this.elem = elem;
      this.data = data;
      this.back = new PolygonView(this.elem, this.data, 'back', {
        x: 252,
        y: 262
      });
      this.hide();
    }

    WalkingBirdBack.prototype.show = function() {
      return this.back.show().scale(0);
    };

    WalkingBirdBack.prototype.hide = function() {
      return this.back.hide().scale(0);
    };

    WalkingBirdBack.prototype.up = function() {
      return this.back.scale(0, upTime);
    };

    WalkingBirdBack.prototype.down = function() {
      return this.back.scale(1, downTime);
    };

    return WalkingBirdBack;

  })();

  WalkingBirdBody = (function() {
    function WalkingBirdBody(elem, data) {
      this.elem = elem;
      this.data = data;
      this.body = new PathView(this.elem, this.data, 'body');
      this.body.hide();
      this.body_after = new PathView(this.elem, this.data, 'body_after');
      this.body_after.hide();
      this.body_fly = new PathView(this.elem, this.data, 'body_fly');
      this.body_fly.hide();
    }

    WalkingBirdBody.prototype.up = function() {
      return this.body.show().changeD(this.body_after.d(), upTime);
    };

    WalkingBirdBody.prototype.down = function() {
      return this.body.show().changeD(this.body_fly.d(), downTime);
    };

    WalkingBirdBody.prototype.show = function() {
      return this.body.show().changeD(this.body_after.d(), time / 2);
    };

    WalkingBirdBody.prototype.hide = function() {
      this.body.show().changeD(this.body.d(), time / 2);
      return setTimeout((function(_this) {
        return function() {
          return _this.body.hide();
        };
      })(this), 100);
    };

    return WalkingBirdBody;

  })();

  WalkingBirdEye = (function() {
    function WalkingBirdEye(elem, data) {
      this.elem = elem;
      this.data = data;
      this.white_eye = new CircleView(this.elem, this.data, 'white_eye', 30, {
        x: 307,
        y: 270
      });
      this.white_eye.hide().circleScale(0.3);
      this.black_eye = new CircleView(this.elem, this.data, 'black_eye', 17, {
        x: 307,
        y: 270
      });
      this.black_eye.hide().circleScale(0.3);
    }

    WalkingBirdEye.prototype.show = function() {
      this.white_eye.show().circleScale(1, time / 2);
      return this.black_eye.show().circleScale(1, time / 2);
    };

    WalkingBirdEye.prototype.hide = function() {
      this.white_eye.show().circleScale(0.3, time / 2);
      this.black_eye.show().circleScale(0.3, time / 2);
      return setTimeout((function(_this) {
        return function() {
          _this.white_eye.hide();
          return _this.black_eye.hide();
        };
      })(this), 100);
    };

    return WalkingBirdEye;

  })();

  WalkingBirdLegs = (function() {
    function WalkingBirdLegs(elem, data) {
      this.elem = elem;
      this.data = data;
      this.leftLeg = new WalkingBirdLeg(this.elem, this.data, 'left', {
        x: 248,
        y: 337
      });
      this.rightLeg = new WalkingBirdLeg(this.elem, this.data, 'right', {
        x: 260,
        y: 337
      });
    }

    WalkingBirdLegs.prototype.show = function() {
      this.leftLeg.show();
      return this.rightLeg.show();
    };

    WalkingBirdLegs.prototype.hide = function() {
      this.leftLeg.hide();
      return this.rightLeg.hide();
    };

    WalkingBirdLegs.prototype.up = function() {
      this.leftLeg.up();
      return this.rightLeg.up();
    };

    WalkingBirdLegs.prototype.down = function() {
      this.leftLeg.down();
      return this.rightLeg.down();
    };

    return WalkingBirdLegs;

  })();

  WalkingBirdLeg = (function() {
    function WalkingBirdLeg(elem, data, side, origin) {
      this.elem = elem;
      this.data = data;
      this.side = side;
      this.leg = new PathView(this.elem, this.data, "" + this.side + "_leg", origin);
      this.hide();
    }

    WalkingBirdLeg.prototype.show = function() {
      return this.leg.show().scale(1, time / 2);
    };

    WalkingBirdLeg.prototype.hide = function() {
      return this.leg.hide().scale(0);
    };

    WalkingBirdLeg.prototype.up = function() {
      return this.leg.rotate(0, upTime);
    };

    WalkingBirdLeg.prototype.down = function() {
      return this.leg.rotate((this.side === 'left' ? 30 : -30), downTime);
    };

    return WalkingBirdLeg;

  })();

  WalkingBirdWings = (function() {
    function WalkingBirdWings(elem, data) {
      this.elem = elem;
      this.data = data;
      this.leftWing = new WalkingBirdWing(this.elem, this.data, 'left');
      this.rightWing = new WalkingBirdWing(this.elem, this.data, 'right');
    }

    WalkingBirdWings.prototype.open = function() {
      this.leftWing.open();
      this.rightWing.open();
      return setTimeout((function(_this) {
        return function() {
          return _this.showBelow();
        };
      })(this), time);
    };

    WalkingBirdWings.prototype.close = function() {
      this.hideBelow();
      return setTimeout((function(_this) {
        return function() {
          _this.leftWing.close();
          return _this.rightWing.close();
        };
      })(this), time / 2);
    };

    WalkingBirdWings.prototype.hideBelow = function() {
      this.leftWing.hideBelow();
      return this.rightWing.hideBelow();
    };

    WalkingBirdWings.prototype.showBelow = function() {
      this.leftWing.showBelow();
      return this.rightWing.showBelow();
    };

    WalkingBirdWings.prototype.up = function() {
      this.leftWing.up();
      return this.rightWing.up();
    };

    WalkingBirdWings.prototype.down = function() {
      this.leftWing.down();
      return this.rightWing.down();
    };

    return WalkingBirdWings;

  })();

  WalkingBirdWing = (function() {
    function WalkingBirdWing(elem, data, side) {
      var gap, origin, target;
      this.elem = elem;
      this.data = data;
      this.side = side;
      gap = 40;
      origin = this.side === 'left' ? {
        x: wingOrigin.x - gap,
        y: wingOrigin.y - gap
      } : {
        x: wingOrigin.x + gap,
        y: wingOrigin.y - gap
      };
      this.group = new GroupView(this.elem, "" + this.side + "_wing_group", origin);
      target = this.group.target();
      this.wing = new PathView(target, this.data, "" + this.side + "_wing");
      this.wingAfter = new PathView(target, this.data, "" + this.side + "_wing_after");
      this.wing.hide();
      this.wingAfter.hide();
      this.leaf = new PathView(target, this.data, "" + this.side + "_leaf", _.clone(wingOrigin));
      this.leaf.rotate(this.rotation(), 0);
    }

    WalkingBirdWing.prototype.rotation = function() {
      if (this.side === 'left') {
        return -135;
      } else {
        return 135;
      }
    };

    WalkingBirdWing.prototype.open = function() {
      return this.leaf.rotate(0, time);
    };

    WalkingBirdWing.prototype.close = function() {
      return this.leaf.rotate(this.rotation(), time / 2);
    };

    WalkingBirdWing.prototype.showBelow = function() {
      return this.wing.show().changeD(this.wingAfter.d(), time / 2);
    };

    WalkingBirdWing.prototype.hideBelow = function() {
      this.wing.show().changeD(this.wing.d(), time / 2);
      return setTimeout((function(_this) {
        return function() {
          return _this.wing.hide();
        };
      })(this), time / 2);
    };

    WalkingBirdWing.prototype.up = function() {
      return this.group.rotate(0, upTime);
    };

    WalkingBirdWing.prototype.down = function() {
      return this.group.rotate((this.side === 'left' ? 20 : -20), downTime);
    };

    return WalkingBirdWing;

  })();

  Tree = (function() {
    function Tree(elem, width, height, walkingBirdData, walkingBirdScale) {
      this.elem = elem;
      this.width = width;
      this.height = height;
      this.walkingBirdData = walkingBirdData;
      this.walkingBirdScale = walkingBirdScale;
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
      var link, node, walkingBirdData, walkingBirdScale;
      walkingBirdData = this.walkingBirdData;
      walkingBirdScale = this.walkingBirdScale;
      link = this.link().data(this.links());
      link.enter().insert('line', '.node').attr('class', 'link');
      node = this.node().data(this.nodes());
      node.enter().insert('g', '.cursor').attr('class', 'node').each(function(d) {
        var el, wb, wbg;
        el = d3.select(this);
        if (d.last === true && Math.random() < .05) {
          el.classed('walking_bird_group', true);
          wbg = new GroupView(el, 'wbg');
          wb = new WalkingBird(wbg.elem(), 'walking_bird', walkingBirdData);
          wbg.scale(walkingBirdScale).rotate(d.rotation);
          return d.wbg = wbg;
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
                      last: count === max,
                      rotation: ~~(Math.random() * 80) + 5
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
        node.x += Math.random() * ran;
        if (node.wbg) {
          node.rotation = ~~(Math.random() * 160) - 80;
          return node.wbg.rotate(node.rotation);
        }
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

  walkingBirdData = void 0;

  walkingBirdScale = .1;

  walkingBirds = [];

  openBirds = function(svg) {
    var count, end, iid, open, parent;
    parent = svg.append('g');
    svg.selectAll('.walking_bird_group').each(function(d) {
      var group, wb;
      group = new GroupView(parent, 'wbg');
      group.translate(d);
      wb = new WalkingBird(group.elem(), 'walking_bird', walkingBirdData);
      group.scale(walkingBirdScale).rotate(d.rotation);
      d.a = ~~(Math.random() * 20) + 15;
      d.el = wb;
      d.group = group;
      return walkingBirds.push(d);
    }).remove();
    count = 0;
    end = 100;
    open = 20;
    return iid = setInterval(function() {
      var d, deg, group, index, pos, _i, _j, _len, _len1, _results;
      for (index = _i = 0, _len = walkingBirds.length; _i < _len; index = ++_i) {
        d = walkingBirds[index];
        group = d.group;
        pos = group.translate();
        if (d.open) {
          pos.scale = walkingBirdScale + .03 * (count - open) / open;
          pos.y += Math.pow(1.005, count);
          if (!(group.rotation() < 10)) {
            pos.deg = (group.rotation() + d.a / 2) % 360;
          }
        } else {
          pos.x += d.a / 4;
          pos.y += Math.pow(1.04, count);
          pos.deg = (group.rotation() + d.a) % 360;
        }
        group.translate(pos);
        if (count === open && index % 3 === 0) {
          d.openCount = open + ~~(Math.random() * 30);
        }
        if (count === d.openCount) {
          d.el.open(function(el) {
            el.flyFlag = true;
            return el.fly();
          });
          d.open = true;
        }
      }
      if (++count > end) {
        clearInterval(iid);
        _results = [];
        for (index = _j = 0, _len1 = walkingBirds.length; _j < _len1; index = ++_j) {
          d = walkingBirds[index];
          group = d.group;
          if (d.open) {
            deg = ~~(Math.random() * 12) - 6;
            _results.push(group.rotate(deg, 1500));
          } else {
            _results.push(group.remove());
          }
        }
        return _results;
      }
    }, 33);
  };

  start = function() {
    var force, group, height, initX, svg, tree, width;
    width = window.innerWidth;
    height = window.innerHeight;
    initX = 200;
    force = void 0;
    svg = d3.select('body').append('svg').attr('width', width).attr('height', height);
    group = svg.append('g').attr('id', 'tree');
    tree = new Tree(group, initX, height, walkingBirdData, walkingBirdScale);
    return tree.createBranch(function() {
      var count, end, iid;
      count = 0;
      end = 30;
      return iid = setInterval(function() {
        if (Math.random() < .2) {
          tree.wind();
        }
        if (++count > end) {
          tree.wind(50);
          openBirds(svg);
          clearInterval(iid);
          return group.transition().duration(2500).attr('transform', 'translate(-' + (initX * 3) + ',0)').each('end', function() {
            tree.stop();
            return group.remove();
          });
        }
      }, 100);
    });
  };

  loadSVG = function(id, onComplete) {
    return d3.xml("svg/" + id + ".svg", 'image/svg+xml', function(data) {
      walkingBirdData = data;
      if (onComplete) {
        return onComplete(data);
      }
    });
  };

  init = function() {
    return loadSVG('walking_bird', start);
  };

  init();

}).call(this);
