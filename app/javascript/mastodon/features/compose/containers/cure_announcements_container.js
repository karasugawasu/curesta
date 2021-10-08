import { connect } from 'react-redux';
import CureAnnouncements from '../components/cure_announcements';
import { toggleCureAnnouncements } from '../../../actions/cure_announcements';

const mapStateToProps = (state) => ({
  visible: state.getIn(['cure_announcements', 'visible']),
});

const mapDispatchToProps = (dispatch) => ({
  onToggle () {
    dispatch(toggleCureAnnouncements());
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(CureAnnouncements);
