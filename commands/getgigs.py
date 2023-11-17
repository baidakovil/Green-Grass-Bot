import logging

from telegram import ReplyKeyboardRemove, Update
from telegram.ext import CallbackContext

from db.db import Db
from services.message_service import reply
from ui.news_builders import prepare_gigs_text

db = Db()

logger = logging.getLogger('A.get')
logger.setLevel(logging.DEBUG)


async def getgigs(update: Update, context: CallbackContext) -> None:
    """
    Callback function. Send list of artists with new concerts to user.
    Args:
        update, context: standart PTB callback signature
    """
    user_id = update.message.from_user.id
    text = await prepare_gigs_text(user_id, request=True)
    if text:
        await reply(update, text, reply_markup=ReplyKeyboardRemove())
        logger.info(f'Gigs sent to user {user_id}')
        return None
    else:
        logger.info(f'Got empty gigs text. Nothing to send to {user_id}')
        return None


async def getgigs_job(context: CallbackContext) -> None:
    """
    Callback function for job scheduler. Send list of artists with new concerts to user.
    Args:
        context: context object generated by telegram.ext.Application
        when user adds lastfm useracc
    """
    logger.info('Start getEventsJob')
    user_id = context.job.user_id
    text = await prepare_gigs_text(user_id, request=False)
    if text:
        await context.bot.send_message(
            chat_id=context.job.chat_id, text=text, parse_mode='MarkdownV2'
        )
        logger.info(f'Job done, gigs sent to user {user_id}')
        return None
    else:
        logger.info(f'Got empty gigs text. Nothing to send to {user_id}')
        return None
