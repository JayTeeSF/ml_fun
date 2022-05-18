const vector = {
  type: 'vector',
  arr: [],
  // clone: function() { return this._clone() }
  copy: function() {
    const c = this._blank()
    c.push(this.arr);
    return c;
  },
  make: function(args=[]) {
    const c = this._blank();
    c.arr = args;
    return c
  },
  join: function(joinStr) {
    return this.arr.join(joinStr);
  },
  concat: function() {
    return this.arr.concat();
  },
  pop: function() {
    return this.arr.pop();
  },
  push: function(v) {
    if ((isNaN(v)) && (typeof(v) != 'object')) {
      return false
    }
    if (typeof(v) == 'object') {
      for (let i = 0; i < v.length; i++) {
        this.arr.push(v[i])
      }
      return true;
    } else {
      return this.arr.push(v);
    }
  },
  // this is janky, cuz normal numbers don't have a pow function!
  // we really need to override Math.pow with this mapping ability!
  pow: function(e) {
    return this.make(this.arr.map(this._powOf(e)));
  },
  dividedBy: function(operand) {
    if ((typeof operand == 'object') && (!Array.isArray(operand)) && (operand.type == 'vector')) {
      if (vector.length == operand.length) {
        //console.log("vector / vector division...")
        return this.make(this.arr.map(this._divPer(operand)));

      } else {
        console.log("FAILED vector / vector division...")
      }
    } else {
      //console.log("vector / scalar division...")
      return this.make(this.arr.map(this._divBy(operand)));
    }
  },
  times: function(operand) {
    if ((typeof operand == 'object') && (!Array.isArray(operand)) && (operand.type == 'vector')) {
      if (vector.length == operand.length) {
        //console.log("vector * vector multiplication...")
        return this.make(this.arr.map(this._multPer(operand)));
      } else {
        console.log("FAILED vector * vector multiplication...")
      }
    } else {
      //console.log("vector * scalar multiplication...")
      return this.make(this.arr.map(this._multBy(operand)));
    }
  },
  minus: function(operand) {
    if ((typeof operand == 'object') && (!Array.isArray(operand)) && (operand.type == 'vector')) {
      if (vector.length == operand.length) {
        //console.log("vector - vector subtraction...")
        return this.make(this.arr.map(this._subPer(operand)));
      } else {
        console.log("FAILED vector - vector subtraction...")
      }
    } else {
      //console.log("vector - scalar subtraction...")
      return this.make(this.arr.map(this._subBy(operand)));
    }
  },
  plus: function(operand) {
    if ((typeof operand == 'object') && (!Array.isArray(operand)) && (operand.type == 'vector')) {
      if (vector.length == operand.length) {
        //console.log("vector + vector addition...")
        return this.make(this.arr.map(this._addPer(operand)));
        // return this.arr.map((e, idx) => { console.log('e: ' + e + ' second-e ' + operand[idx] + ' = ' + e + operand[idx]); });
      } else {
        console.log("FAILED vector + vector addition...")
      }
    } else {
      //console.log("vector + scalar addition...")
      return this.make(this.arr.map(this._addBy(operand)));
    }
  },
  length: function() {
    return this.arr.length;
  },
  sum: function() {
    return this.arr.reduce(function (a, b) {
      return a + b;
    }, 0);
  },
  avg: function() {
    return this.sum() / this.length();
  },
  _clone: function() {
    return {...this};
  },
  _blank: function() {
    const objectCopy = {...this, arr: []};
    return objectCopy;
  },
  _powOf: function(e) {
    return (i) => { return Math.pow(i,e); };
  },
  _multBy: function(incr) {
    return (i) => { return i * incr; };
  },
  _multPer: function(otherVector) {
    return (i, idx) => { return i * otherVector.arr[idx]; };
  },
  _addBy: function(incr) {
    return (i) => { return i + incr; };
  },
  _addPer: function(otherVector) {
    return (i, idx) => { return i + otherVector.arr[idx]; };
  },
  _subBy: function(incr) {
    return (i) => { return i - incr; };
  },
  _subPer: function(otherVector) {
    return (i, idx) => { return i - otherVector.arr[idx]; };
  },
  _divBy: function(incr) {
    return (i) => { return i / incr; };
  },
  _divPer: function(otherVector) {
    return (i, idx) => { return i / otherVector.arr[idx]; };
  },
}

const model = {
  w: 0,
  b: 0,
  predictWith: function() {
    const wInput  = document.getElementById('weight').value;
    const bInput  = document.getElementById('bias').value;
    const XInputs  = document.getElementById('TestX');
    const YOutputs  = document.getElementById('TestY');
    const XValues = (XInputs.value == '' ? XInputs.placeholder : XInputs.value).split(','); // one or more #'s
    /\d+/.test(XValues) ? YOutputs.value = this.predict(XValues.map(parseFloat), parseFloat(wInput), parseFloat(bInput)).join(", ") : alert("Input X value(s)")
  },
  predict: function(X, weight=this.w, bias=this.b) {
    const vX = isNaN(X) ? vector.make(X.concat()) : vector.make([X]);
    const result = vX.times(weight).plus(bias)
    return isNaN(X) ? result : result.concat()[0];
  },
}

const Xarr = [ -1, 0, 1, 2, 3, 4];
const Yarr = [ -2, 1, 4, 7, 10, 13];

const trainer = {
  // it needs a 'vector' in order to call 'vector.make' !?! 
  learningRate: 0.0001,
  iterations: 20000,

  loss: function(X, Y, w, b, prediction=null) {
    const vY = isNaN(Y) ? vector.make(Y.concat()) : vector.make([Y]);
    prediction ||= model.predict(X, w, b);
    const lossValue = (prediction.minus(vY)).pow(2).avg();
    // console.log(`for(${X}, ${Y}, using: ${w} and ${b}) prediction: ${prediction.concat()} => ${lossValue}`);
    return lossValue;
  },

  gradient: function(X, Y, w, b, prediction=null) {
    const vX = isNaN(X) ? vector.make(X.concat()) : vector.make([X]);
    const vY = isNaN(Y) ? vector.make(Y.concat()) : vector.make([Y]);
    prediction ||= model.predict(X, w, b)
    var predictionMinusVy = prediction.minus(vY); // calculate this once per call
    //console.log(`vX: ${vX.concat()}, predictionMinusVy: ${predictionMinusVy.concat()}`)
    const gradientWithRespectToW = 2 * (vX.times(predictionMinusVy)).avg();
    const gradientWithRespectToB = 2 * (predictionMinusVy).avg();
    const gradientValues = [gradientWithRespectToW, gradientWithRespectToB];
    //console.log(`gradientValues: ${gradientValues}`);
    return gradientValues;
  },

  trainTo: function(outputId, iterations=this.iterations, lr=this.learningRate) {
    const XInputs  = document.getElementById('TrainingX');
    const YOutputs  = document.getElementById('TrainingY');
    const YTrainingOutputs = (YOutputs.value == '' ? YOutputs.placeholder : YOutputs.value).split(','); // one or more #'s
    const XTrainingInputs = (XInputs.value == '' ? XInputs.placeholder : XInputs.value).split(','); // one or more #'s
    // const XTrainingInputs = XInputs.value.split(','); // one or more #'s
    this.train(XTrainingInputs,YTrainingOutputs,iterations,lr, outputId)
  },

  train: function(X=Xarr, Y=Yarr, iterations=this.iterations, lr=this.learningRate, outputId=null) {
    var lossVal, gd, wGradient, bGradient, prediction;
    var w = 0;
    var b = 0;
    var pTag, subPTag, wInput, bInput;
    if (outputId != null) {
      pTag  = document.getElementById(outputId)
      wInput  = document.getElementById('weight')
      bInput  = document.getElementById('bias')
    }
    var messages = [];
    for(let i = 0; i < iterations; i++) {
      prediction = model.predict(X, w, b); // calculate this once per loop!
      lossVal = this.loss(X, Y, w, b, prediction);
      gd = this.gradient(X, Y, w, b, prediction);
      //[wGradient, bGraident] 
      wGradient = gd[0];
      bGradient = gd[1];
      //console.log(`wGradient: ${wGradient}, bGradient: ${bGradient}`);
      w = w - wGradient * lr;
      b = b - bGradient * lr;
      if (null == outputId) {
        console.log(`Iteration ${i} => Loss: ${lossVal}, w: ${w}, b: ${b}`);
      } else {
        messages.push(`Iteration ${i} => Loss: ${lossVal}, w: ${w}, b: ${b}`)
      }
    }

    if (null != outputId) {
      for(let i=0; i< messages.length; i++) {
        subPTag = document.createElement("p")
        subPTag.innerHTML = messages.pop()
        pTag.appendChild(subPTag)
      }
    }

    if (outputId != null) {
      wInput.value = w 
      bInput.value = b 
    }
    return [w, b];
  },
}
