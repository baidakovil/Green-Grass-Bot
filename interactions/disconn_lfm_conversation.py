import logging

from telegram import ReplyKeyboardMarkup, ReplyKeyboardRemove, Update
from telegram.ext import (
    CallbackContext,
    CommandHandler,
    ConversationHandler,
    MessageHandler,
    filters,
)

from db.db import Db
from interactions.common_handlers import cancel_handle
from services.message_service import i34g, reply

logger = logging.getLogger('A.dis')
logger.setLevel(logging.DEBUG)

db = Db()

DISC_ACC = 0


async def disconnect(update: Update, context: CallbackContext) -> int:
    """
    Entry point. Offers to user saved accounts from database to delete, or replies about
    there is no accounts.
    Args:
        update, context: standart PTB callback signature
    Returns:
        signals for stop or next step of conversation
    """
    user_id = update.message.from_user.id
    lfm_accs = await db.rsql_lfmuser(update.message.from_user.id)
    if lfm_accs:
        text = await i34g("disconn_lfm_conversation.choose_acc", user_id=user_id)
        lfm_accs.append('/cancel')
        await reply(
            update,
            text,
            reply_markup=ReplyKeyboardMarkup(
                [lfm_accs],
                one_time_keyboard=True,
                resize_keyboard=True,
            ),
        )
        return DISC_ACC
    else:
        await reply(
            update, await i34g("disconn_lfm_conversation.no_accs", user_id=user_id)
        )
        return ConversationHandler.END


async def disconn_lfm(update: Update, context: CallbackContext) -> int:
    """
    Second step. Waits for answer which account to delete, delete it, replies.
    Args:
        update, context: standart PTB callback signature
    Returns:
        signals for stop or next step of conversation
    """
    user_id = update.message.from_user.id
    useraccs = await db.rsql_lfmuser(user_id)
    acc = update.message.text.lower()
    if acc == '/cancel':
        #  Code of the condition only for removing keyboard
        del_msg = await update.message.reply_text(
            'ok', reply_markup=ReplyKeyboardRemove()
        )
        await context.bot.deleteMessage(
            message_id=del_msg.message_id, chat_id=update.message.chat_id
        )
        return ConversationHandler.END
    elif acc not in useraccs:
        text = await i34g(
            "disconn_lfm_conversation.acc_not_found", acc=acc, user_id=user_id
        )
    else:
        affected_scr, affected_ua = await db.dsql_useraccs(user_id, acc)
        if affected_scr and affected_ua:
            text = await i34g(
                "disconn_lfm_conversation.acc_scr_deleted", acc=acc, user_id=user_id
            )
            logger.info(f"User {user_id} deleted account {acc},scrobbles deleted")
        elif affected_ua:
            text = await i34g(
                "disconn_lfm_conversation.acc_deleted", acc=acc, user_id=user_id
            )
            logger.info(f"User {user_id} deleted account {acc}, no scrobbles deleted")
        else:
            text = await i34g(
                "disconn_lfm_conversation.error_when_del", acc=acc, user_id=user_id
            )
            logger.warning(f"Error when {user_id} deleted account {acc}")
    await reply(update, text, reply_markup=ReplyKeyboardRemove())
    return ConversationHandler.END


def disconn_lfm_conversation() -> ConversationHandler:
    """
    Returns conversation handler to add lastfm user.
    """
    states = {DISC_ACC: [MessageHandler(filters.TEXT, disconn_lfm)]}
    disconn_lfm_handler = ConversationHandler(
        entry_points=[CommandHandler('disconnect', disconnect)],
        states=states,
        fallbacks=[CommandHandler('cancel', cancel_handle)],
    )
    return disconn_lfm_handler
