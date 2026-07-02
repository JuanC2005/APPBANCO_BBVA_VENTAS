import asyncio

from supabase import Client, create_client

from app.core.config import settings

supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_KEY)
supabase_auth: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_ANON_KEY)


def get_supabase() -> Client:
    return supabase


def get_supabase_auth() -> Client:
    return supabase_auth


async def supabase_execute(query):
    return await asyncio.to_thread(query.execute)
