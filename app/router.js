import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('exercises', function() {
    this.route('new');

    this.route('show', {
      path: ':exercise_id'
    });

    this.route('edit', {
      path: ':exercise_id/edit'
    });
  });
  this.route('routines', function() {
    this.route('new');
  });
});

export default Router;
