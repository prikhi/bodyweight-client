import DS from 'ember-data';

export default DS.RESTAdapter.extend({
  headers: {
    "Accept": 'application/json',
  }
});
