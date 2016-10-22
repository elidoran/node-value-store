# ValueStore
[![Build Status](https://travis-ci.org/elidoran/node-value-store.svg?branch=master)](https://travis-ci.org/elidoran/node-value-store)
[![Dependency Status](https://gemnasium.com/elidoran/node-value-store.png)](https://gemnasium.com/elidoran/node-value-store)
[![npm version](https://badge.fury.io/js/value-store.svg)](http://badge.fury.io/js/value-store)

Get/set values on hierarchy of objects.

For example, a hierarchy of configuration files could be turned into a 'value-store'. Then it can be queried for the closest key with a value, or, for all values for a key.

Note, I'm using this in [nuc](https://npmjs.com/package/nuc).

## Install

```sh
npm install value-store --save
```

## Usage

```javascript
// require the module
var buildStore = require('value-store')
  // we can provide an array of objects as the initial hierarchy
  , initialValues = [
    { first: true, name:'first' }
    , { second: true, name:'second' }
    , { third: true, name:'third' }
  ]
  // build the instance, provide the array of initial values
  , values = buildStore(initialValues);

// outputs:  
/*
first ? true
second? true
third ? true
name  : first
name  : [ 'first', 'second', 'third' ]
third is in 2
first in third? false
count: 3
has third? true
info for second: { value:true, in:1, overridden:false }
info for name: { value:'first', in:0, overridden:false }
info for name in 1: { value:'second', in:1, overridden:true }
source of 0: constructor
source of 5: undefined
*/
console.log('first ?',values.get('first'));
console.log('second?',values.get('second'));
console.log('third ?',values.get('third'));
console.log('name  :',values.get('name'));
console.log('name  :',values.all('name'));
console.log('third is in',values.in('third'));
console.log('first in third?',values.get('first', 2));
console.log('count:',values.count());
console.log('has third?',values.has('third'));
console.log('info for second:',values.info('second'));
console.log('info for name:',values.info('name'));
console.log('info for name in 1:',values.info('name', 1));
console.log('source of 0:', values.source(0));
console.log('source of 5:', values.source(5));

// let's change it by setting other values in there

// this puts enabled:true into the first object.
values.set('enabled', true);

// this overrides the current value in the first object
values.set('name', 'primary');

// this overrides the current value in the third object
values.set('name', 'tertiary', 2);

// add an entirely new object as the last object
values.append({ name:'last', something: 'new'});

// add an entirely new object as the first object.
// this essentially overrides all the others.
values.prepend({ name:'overrider' });

// add values from a file (specify path)
values.append('./some/file.json');

// rerun the above series and the new output will be:
/*
first ? true
second? true
third ? true
name  : overrider
name  : [ 'overrider', 'primary', 'second', 'tertiary', 'last' ]
third is in 3
first in third? false
count: 6
has third? true
info for second: { value:true, in:2, overridden:false }
info for name: { value:'overrider', in:0, overridden:false }
info for name in 1: { value:'primary', in:1, overridden:true }
source of 0: prepend
source of 5: { file: './some/file.json' }
*/

// others: shift() is like array.shift(). removes the first array element
var result = values.shift();
// is: {
//   removed: [
//      { /* the object with name='overrider' */ }
//   ]
// }
//

// others: pop() is like array.shift(). removes the last array element
result = values.pop();
// is: {
//   removed: [
//     { /* the object with name='overrider' */ }
//   ]
// }

// the result is an array because you can shift/pop more than one by
// specifying how many:
// this removes the first two
values.shift(2);
// this removes the last two
values.pop(2);
// so, now there are the 2 middle ones left.

// when a file is added via its path the path is recorded as its 'source'
values.append('./some/file.json');
// then, that object can be written back to its source.
// let's say the above append put that file as source 3 (4th in array).
// then this would write it back out
values.write(3);
// it will be written as json because the extension is .json
// to alter where it's written to and the format you may pass options:
values.write(3, { file: './some/other/file.ini' });
// the above will be written as an INI file because the extension is '.ini'.
// you may also specify the format:
values.write(3, { file: './other.conf', format:'ini' });
// JSON is the default format. INI is the alternate format.

```

## MIT License
