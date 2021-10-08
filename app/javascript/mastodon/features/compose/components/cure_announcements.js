import React from 'react';
import Immutable from 'immutable';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { Link } from 'react-router-dom';

const cure_announcements = Immutable.fromJS([
  {
    body: 'モロヘイヤ',
    links: [
      {href: '/mulukhiya', body: 'Home'},
      {href: '/mulukhiya/app/config', body: '設定'},
      {href: '/mulukhiya/app/media', body: 'メディア'},
      {href: '/mulukhiya/app/api', body: 'API'},
    ]
  }
]);

export default class CureAnnouncements extends React.PureComponent {

  static propTypes = {
    visible: PropTypes.bool.isRequired,
    onToggle: PropTypes.func.isRequired,
  }

  render () {
    const { visible, onToggle } = this.props;
    const caretClass = visible ? 'fa fa-caret-down' : 'fa fa-caret-up';
    return (
      <div className='cure_announcements'>
        <div className='compose__extra__header'>
          <i className='fa fa-link' />
          おしらせ＆関連リンク
          <button className='compose__extra__header__icon' onClick={onToggle} >
            <i className={caretClass} />
          </button>
        </div>
        { visible && (
          <ul>
            {cure_announcements.map((cure_announcement, idx) => (
              <li key={idx}>
                <div className='cure_announcements__icon'>
                  <i className='fa fa-bookmark' />
                </div>
                <div className='cure_announcements__body'>
                  <p>{cure_announcement.get('body')}</p>
                  <div className='links'>
                    {cure_announcement.get('links').map((link, i) => (
                      link.get('link') === true
                      ? <Link to={link.get('href')}>
                          {link.get('body')}
                        </Link>
                      : <a href={link.get('href')} target='_blank' key={i}>
                          {link.get('body')}
                        </a>
                    ))}
                  </div>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>
    );
  }

}
