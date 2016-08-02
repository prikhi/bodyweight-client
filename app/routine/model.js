import DS from 'ember-data';

export default DS.Model.extend({
  name: DS.attr('string'),
  isPublic: DS.attr('boolean'),
  copyright: DS.attr('string'),
  sections: DS.hasMany('section'),
});
