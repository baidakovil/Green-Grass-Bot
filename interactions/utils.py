import logging
from datetime import datetime

from config import Cfg

logger = logging.getLogger('A.uti')
logger.setLevel(logging.DEBUG)

CFG = Cfg()


def timestamp_to_text(timestamp: datetime) -> str:
    """
    Convertor for saving timestamps to SQL. Used when write info about user
    registration.
    Args:
        timestamp: timestamp
    Returns:
        string with specific timestamp format
    """
    f_sql = '%Y-%m-%d %H:%M:%S'
    return timestamp.strftime(f_sql)


def text_to_userdate(text: str) -> str:
    """
    Convertor from SQL-storing format '2023-01-02' to '02 Jan 2023' for humans. Used
    when preparing 'details', i.e. event news.
    Args:
        text: string with specific date format
    Returns:
        string with specific date format
    """
    f_sql = '%Y-%m-%d'
    f_hum = '%d %b %Y'
    return datetime.strptime(text, f_sql).strftime(f_hum)


def lfmdate_to_text(lfmdate: str) -> str:
    """
    Convertor for saving dates from last.fm '15 Nov 2023' to SQL '2023-11-15'. Used when
    saving scrobbles.
    Args:
        lfmdate: string with specific date format
    Returns:
        string with specific date format
    """
    f_lfm = '%d %b %Y'
    f_sql = '%Y-%m-%d'
    return datetime.strptime(lfmdate, f_lfm).strftime(f_sql)
