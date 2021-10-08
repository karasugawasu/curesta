import Immutable from 'immutable';
import { TOGGLE_CUREANNOUNCEMENTS } from '../actions/cure_announcements';

const initialState = Immutable.Map({
  visible: true,
});

export default function cure_announcements(state = initialState, action) {
  switch(action.type) {
  case TOGGLE_CUREANNOUNCEMENTS:
    return state.set('visible', !state.get('visible'));
  default:
    return state;
  }
};
